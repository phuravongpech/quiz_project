import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';

class Participant {
  final int id;
  final String name;

  Participant({required this.id, required this.name});

  Future<void> insert() async {
    var conn = await MySqlConnection.connect(settings);
    try {
      await conn.query('INSERT INTO participant(name) VALUES (?)', [name]);
    } catch (e) {
      print(e);
      throw Exception('Failed to insert participant: $e');
    } finally {
      await conn.close();
    }
  }

  static Future<List<Participant>> getAll() async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var result = await conn.query('SELECT * FROM participant');

      return result
          .map((row) => Participant(id: row['id'], name: row['name']))
          .toList();
    } catch (e) {
      print('Failed to get participants: $e');
      throw Exception('Failed to get participants');
    } finally {
      await conn.close();
    }
  }
}
