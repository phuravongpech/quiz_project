import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';
import 'answer.dart';

enum QuestionType {
  singleQuestion(1),
  multipleQuestion(2);

  final int value;
  const QuestionType(this.value);

  static QuestionType fromValue(dynamic value) {
    if (value is String) {
      return QuestionType.values.firstWhere((type) => type.name == value);
    } else {
      throw Exception('Unexpected question type value: $value');
    }
  }
}

class Question {
  final int id;
  int quizId;
  final String title;
  final QuestionType questionType;
  final List<Answer>? answerChoices;
  final List<int> correctAnswers;

  Question({
    required this.id,
    required this.quizId,
    required this.title,
    required this.questionType,
    required this.answerChoices,
    required this.correctAnswers,
  });

  @override
  String toString() {
    return '$title (${questionType == QuestionType.singleQuestion ? 'Single Choice' : 'Multiple Choice'})\n  Answers:\n${answerChoices!.map((a) => '    ${a.toString()}').join('\n')}\nCorrect Answers: ${correctAnswers.map((i) => answerChoices![i].text).join(', ')}';
  }

  bool isAnswerCorrect(List<int> userSelectedAnswer) {
    if (correctAnswers.isEmpty) {
      print('Warning: No correct answers set for question ID $id.');
      return false;
    }

    if (userSelectedAnswer.isEmpty) return false;

    if (questionType == QuestionType.singleQuestion) {
      return userSelectedAnswer.length == 1 &&
          userSelectedAnswer.first == correctAnswers.first;
    } else {
      return Set<int>.from(correctAnswers).containsAll(userSelectedAnswer) &&
          Set<int>.from(userSelectedAnswer).containsAll(correctAnswers);
    }
  }

  Future<void> insert() async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var result = await conn.query(
        'INSERT INTO question(question_text, quiz_id, question_type) VALUES (?,?,?)',
        [title, quizId, questionType.name],
      );
      int questionId = result.insertId!;

      for (var answer in answerChoices!) {
        final newAnswer = Answer(
            id: 0, // Auto_Increment
            questionId: questionId,
            text: answer.text,
            isCorrect: answer.isCorrect);
        await newAnswer.insert();
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to insert question: $e');
    } finally {
      await conn.close();
    }
  }

  static Future<List<Question>> getByQuizId(dynamic quizId) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      final int intQuizId =
          quizId is String ? int.parse(quizId) : quizId as int;

      var results = await conn.query(
        'SELECT id, question_text, quiz_id, question_type FROM question WHERE quiz_id = ?',
        [intQuizId],
      );

      List<Question> questions = [];
      for (var row in results) {
        var answers = await Answer.getByQuestionId(row['id']);
        var question = Question(
            id: row['id'] as int,
            quizId: row['quiz_id'] as int,
            title: row['question_text'] as String,
            questionType:
                QuestionType.fromValue(row['question_type'] as String),
            answerChoices: answers,
            correctAnswers: answers
                .asMap()
                .entries
                .where((entry) => entry.value.isCorrect)
                .map((entry) => entry.key)
                .toList());
        questions.add(question);
      }
      return questions;
    } catch (e) {
      print('Failed to get questions: $e');
      throw Exception('Failed to get questions');
    } finally {
      await conn.close();
    }
  }
}
