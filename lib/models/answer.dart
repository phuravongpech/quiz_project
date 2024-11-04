import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';

class Answer {
  final int id;
  int questionId;
  final String text;
  final bool isCorrect;
  bool isSelected;

  Answer({
    required this.id,
    required this.questionId,
    required this.text,
    required this.isCorrect,
    this.isSelected = false,
  });

  set selected(bool isSelected) => this.isSelected = true;
  set deselected(bool isSelected) => this.isSelected = false;

  @override
  String toString() {
    return '$text${isCorrect ? ' (Correct)' : ''}';
  }

  Future<void> insert() async {
    var conn = await MySqlConnection.connect(settings);
    try {
      await conn.query(
          'INSERT INTO answer(answer, question_id, is_correct) VALUES (?,?,?)',
          [text, questionId, isCorrect ? 1 : 0]);
    } catch (e) {
      print(e);
      throw Exception('Failed to insert answer: $e');
    } finally {
      await conn.close();
    }
  }

  static Future<List<Answer>> getByQuestionId(int questionId) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var result = await conn
          .query('SELECT * FROM answer WHERE question_id = ?', [questionId]);

      return result
          .map((row) => Answer(
              id: row['id'],
              questionId: row['question_id'],
              text: row['answer'],
              isCorrect: row['is_correct'] == 1))
          .toList();
    } catch (e) {
      print('Failed to get answers: $e');
      throw Exception('Failed to get answers');
    } finally {
      await conn.close();
    }
  }
}
