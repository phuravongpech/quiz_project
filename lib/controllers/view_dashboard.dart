import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';

Future<void> viewDashboard() async {
  final conn = await MySqlConnection.connect(settings);
  try {
    var results = await conn.query(
      'SELECT p.name, q.title, d.participant_score, d.question_total '
      'FROM dashboard d '
      'JOIN participant p ON d.participant_id = p.id '
      'JOIN quiz q ON d.quiz_id = q.id' 
    );

    if (results.isEmpty) {
      print('No dashboard data available.');
      return;
    }

    print('Participant Name  | Quiz Title  | Score');
    print('---------------------------------------');
    for (var row in results) {
      print('${row['name']} | ${row['title']} | ${row['participant_score']}/${row['question_total']}');
    }
  } catch (e) {
    print('Failed to retrieve dashboard data: $e');
  } finally {
    await conn.close();
  }
}