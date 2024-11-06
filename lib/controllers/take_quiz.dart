import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';
import 'package:quiz_project/models/participant.dart';
import 'package:quiz_project/models/quiz.dart';
import 'package:quiz_project/models/quiz_attempt.dart';

Future<void> takeQuiz() async {
  var quizzes = await Quiz.getAll();

  if (quizzes.isEmpty) {
    print('no quizzes available.');
    return;
  }

  print('available quizzes:');
  for (int i = 0; i < quizzes.length; i++) {
    print('${i + 1}. ${quizzes[i].title}');
  }

  stdout.write('choose a quiz by number: ');
  int quizIndex = int.parse(stdin.readLineSync()!) - 1;
  Quiz selectedQuiz = quizzes[quizIndex];

  stdout.write('enter your name: ');
  String? name = stdin.readLineSync();

  Participant participant = Participant(id: 0, name: name!);
  await participant.insert();

  Map<int, List<int>> userAnswers = {};
  int currentQuestion = 0;
  bool isQuizComplete = false;

  while (!isQuizComplete) {
    var question = selectedQuiz.questions[currentQuestion];
    
    print('\n${question.title}');
    for (int i = 0; i < question.answerChoices!.length; i++) {
      print('${i + 1}. ${question.answerChoices![i].text}');
    }

    stdout.write('Enter your answer (,) or type "n" next, "p" back: ');
    String input = stdin.readLineSync()!;

    if (input.toLowerCase() == 'n') {
      if (currentQuestion < selectedQuiz.questions.length - 1) {
        currentQuestion++;
      } else {
        print('You are already at the last question.');
      }
    } else if (input.toLowerCase() == 'p') {
      if (currentQuestion > 0) {
        currentQuestion--;
      } else {
        print('You are already at the first question.');
      }
    } else if (input.toLowerCase() == 'submit' && currentQuestion == selectedQuiz.questions.length - 1) {
      isQuizComplete = true;
    } else {
      try {
        List<int> selected = input.split(',')
            .map((answer) => int.parse(answer.trim()) - 1)
            .toList();
        if (selected.any((index) => index < 0 || index >= question.answerChoices!.length)) {
          throw FormatException('Invalid answer choice');
        }
        userAnswers[question.id] = selected;
        if (currentQuestion < selectedQuiz.questions.length - 1) {
          currentQuestion++;
        } else {
          print('You are at the last question. Type "submit" to complete the quiz');
        }
      } catch (e) {
        print('Invalid input. Please enter valid answer choices or commands.');
      }
    }
  }

  QuizAttempt attempt = QuizAttempt(id: 0, quiz: selectedQuiz, userAnswers: userAnswers);
  attempt.calculateScore();

  final conn = await MySqlConnection.connect(settings);
  try {
    await conn.query(
      'INSERT INTO dashboard(participant_id, quiz_id, participant_score, question_total) VALUES (?,?,?,?)',
      [participant.id, selectedQuiz.id, attempt.score, selectedQuiz.questions.length],
    );
  } catch (e) {
    print('Failed to save quiz attempt: $e');
  } finally {
    await conn.close();
  }

  print('Quiz Completed! Your Score: ${attempt.score}/${selectedQuiz.questions.length}');
}