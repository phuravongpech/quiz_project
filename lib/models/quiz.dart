import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';
import 'question.dart';

class Quiz {
  final int id;
  final String title;
  List<Question> questions;

  Quiz({required this.id, required this.title, required this.questions});

  @override
  String toString() {
    return 'Quiz: $title\nQuestions:\n${questions.map((q) => q.toString()).join('\n')}\n';
  }

  Future<void> insert() async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var result =
          await conn.query('INSERT INTO quiz(title) VALUES (?)', [title]);
      int quizId = result.insertId!;

      for (var question in questions) {
        question.quizId = quizId;
        await question.insert();
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to insert quiz');
    } finally {
      await conn.close();
    }
  }

  static Future<List<Quiz>> getAll() async {
    final conn = await MySqlConnection.connect(settings);
    try {
      var result = await conn.query('SELECT * FROM quiz');

      List<Quiz> quizzes = [];
      for (var row in result) {
        try {
          List<Question> questions =
              await Question.getByQuizId(row['id'].toString());
          var quiz = Quiz(
            id: int.parse(row['id'].toString()),
            title: row['title'].toString(),
            questions: questions,
          );
          quizzes.add(quiz);
        } catch (e) {
          print('Error processing quiz ${row['id']}: $e');
          continue; // Skip this quiz if there's an error
        }
      }
      return quizzes;
    } catch (e) {
      print('Failed to get quizzes: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }
}
