import 'package:quiz_project/models/answer.dart';
import 'package:quiz_project/models/question.dart';

import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';

import 'quiz.dart';
import 'quiz_attempt.dart';
import 'participant.dart';

import 'dart:io';

class QuizApp {
  List<Quiz> quizzes = [];
  List<QuizAttempt> quizAttempts = [];
  List<Participant> participants = [];

  late MySqlConnection db;
  Future<void> initDatabase() async {
    try {
      db = await MySqlConnection.connect(settings);
      print('Database connected successfully');
    } catch (e) {
      print('Failed to connect to database: $e');
      rethrow;
    }
  }

  String? _getString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Blob) return String.fromCharCodes(value.toBytes());
    return value.toString();
  }

  int? _getInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  bool _getBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    return false;
  }

  Future<void> loadQuizzes() async {
    try {
      quizzes.clear();
      var quizResults = await db.query('SELECT * FROM Quiz');

      for (var row in quizResults) {
        var quizId = _getInt(row['id']);
        if (quizId == null) continue;

        var quiz = Quiz(
            id: quizId,
            title: _getString(row['title']) ?? 'Untitled Quiz',
            questions: []);

        var questionResults = await db
            .query('SELECT * FROM Question WHERE quiz_id = ?', [quizId]);

        for (var qRow in questionResults) {
          var questionId = _getInt(qRow['id']);
          if (questionId == null) continue;

          var answerResults = await db.query(
              'SELECT * FROM Answer WHERE question_id = ?', [questionId]);

          List<Answer> answers = [];
          List<int> correctAnswers = [];
          int answerIndex = 0;

          for (var aRow in answerResults) {
            var answerId = _getInt(aRow['id']);
            if (answerId == null) continue;

            answers.add(Answer(
                id: answerId,
                text: _getString(aRow['text']) ?? 'No answer text',
                isCorrect: _getBool(aRow['is_correct'])));

            if (_getBool(aRow['is_correct'])) {
              correctAnswers.add(answerIndex);
            }
            answerIndex++;
          }

          var question = Question(
              id: questionId,
              quizId: quizId,
              title: _getString(qRow['title']) ?? 'Untitled Question',
              questionType: _getString(qRow['question_type']) == 'single'
                  ? QuestionType.singleQuestion
                  : QuestionType.multipleQuestion,
              answerChoices: answers,
              correctAnswers: correctAnswers);

          quiz.addQuestion(question);
        }

        quizzes.add(quiz);
      }

      print('Loaded ${quizzes.length} quizzes successfully');
    } catch (e, stackTrace) {
      print('Error loading quizzes: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> loadAllData() async {
    await initDatabase();
    await loadQuizzes(); // Load quizzes first since attempts need them
  }

  Future<void> homeMenu() async {
    // Load data when starting the app
    await loadAllData();

    while (true) {
      print("\nChoose:");
      print("1. Create quiz");
      print("2. Take quiz");
      print("3. Show quiz score");
      print("4. Exit");
      print("Choose one:");

      String? choice = stdin.readLineSync();
      switch (choice) {
        case '1':
          createQuiz();
          break;
        case '2':
          listQuiz();
          break;
        case '3':
          showQuizAttempt();
          break;
        case '4':
          await db.close();
          return;
        default:
          print("Choose again");
      }
    }
  }

  void createQuiz() {
    print("input quizzes");
    print("enter quiz title:");

    String? title = stdin.readLineSync();

    Quiz quiz = Quiz(id: quizzes.length + 1, title: title!, questions: []);
    print(quiz);

    while (true) {
      print("quiz title : $title");
      print("enter question title : (or 'e' to exit)");
      String? questionTitle = stdin.readLineSync();
      if (questionTitle == null || questionTitle.toLowerCase() == 'e') break;

      print("question type : single or multiple");
      print("s for single, 'm' for multiple ");
      String? questionTypeChoice = stdin.readLineSync();

      QuestionType questionType = questionTypeChoice == 's'
          ? QuestionType.singleQuestion
          : QuestionType.multipleQuestion;

      List<Answer> answers = [];
      List<int> correctAnswers = [];
      for (int i = 0; i < 4; i++) {
        print("answer ${i + 1}");
        String? answerText = stdin.readLineSync();
        if (answerText == null || answerText.isEmpty) break;

        print("is the answer correct? (y/n)");
        String? isCorrectString = stdin.readLineSync();
        bool isCorrect = isCorrectString?.toLowerCase() == 'y';

        if (isCorrect) {
          correctAnswers.add(i);
        }

        Answer answer =
            Answer(id: i + 1, text: answerText, isCorrect: isCorrect);
        answers.add(answer);
      }

      Question question = Question(
          id: quiz.questions.length + 1,
          quizId: quiz.id,
          title: title,
          questionType: questionType,
          answerChoices: answers,
          correctAnswers: correctAnswers);

      quiz.addQuestion(question);
      quizzes.add(quiz);
      print("quiz and ques created");
    }
    for (var q in quizzes) {
      print(q);
    }
  }

  void listQuiz() {
    if (quizzes.isEmpty) {
      print("no quiz yet");
      return;
    }

    print("quiz : ");
    for (var q in quizzes) {
      print("quiz id ${q.id} : ${q.title}");
    }
  }

  void takeQuiz() {
    listQuiz();
    if (quizzes.isEmpty) {
      return;
    }

    //pick quiz when shown the list of quizzes
    print("select quiz num");
    int? quizNum = int.tryParse(stdin.readLineSync() ?? '');
    if (quizNum == null) {
      return;
    }

    Quiz? selectedQuiz = quizzes.firstWhere((quiz) => quiz.id == quizNum);

    print("enter ur name info");
    print("first name");
    String? firstName = stdin.readLineSync();
    print("last name");
    String? lastName = stdin.readLineSync();
    if (firstName == null || lastName == null) {
      return;
    }
    //save prompted user

    Participant participant = Participant(
        id: participants.length + 1, firstName: firstName, lastName: lastName);

    participants.add(participant);

    //map stores { question : [answer choices] for user to pick}
    Map<int, List<int>> userAnswers = {};
    for (var question in selectedQuiz.questions) {
      print("\n${question.title}");
      print("answers:");

      for (int i = 0; i < question.answerChoices!.length; i++) {
        print("$i. ${question.answerChoices![i].text}");
      }

      List<int> userSelectedAnswers = [];
      if (question.questionType == QuestionType.singleQuestion) {
        print("select one answer");
        int? answer = int.tryParse(stdin.readLineSync() ?? '');
        userSelectedAnswers.add(answer!);
      } else {
        print("can select multiple answers (space for next answer)");
        userSelectedAnswers = stdin
                .readLineSync()
                ?.split(' ')
                .map((i) => int.parse(i))
                .toList() ??
            [];
      }

      userAnswers[question.id] = userSelectedAnswers;
    }

    QuizAttempt quizAttempt = QuizAttempt(
        id: quizAttempts.length + 1,
        quiz: selectedQuiz,
        userAnswers: userAnswers);

    quizAttempt.calculateScore();

    quizAttempts.add(quizAttempt);
    print("quiz done");
    print(
        "score : ${quizAttempt.score} / ${selectedQuiz.questions.length * 10}");
  }

  void showQuizAttempt() {
    if (quizAttempts.isEmpty) {
      print("no attempt yet");
      return;
    }

    print("quiz attempts:");
    for (var q in quizAttempts) {
      print("attempt id: ${q.id}");
      print("quiz title: ${q.quiz.title}");
      print("attempt score: ${q.score} / ${q.quiz.questions.length * 10}");
      print("=================================");
    }
  }
}

void main() {
  QuizApp quiz = QuizApp();
  quiz.homeMenu();

  print(quiz.quizzes);
}

