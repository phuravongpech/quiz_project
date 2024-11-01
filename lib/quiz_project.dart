import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';

class Participant{
  final String name;

  Participant(this.name);

  Future<void> insert() async{
    var conn = await MySqlConnection.connect(settings);

    try{
      var result = await conn.query('INSERT INTO participant(name) VALUES (?)', [name]);
      print('Inserted success : ${result.insertId}');
    }
    catch(e){
      print('Failed to insert $e');
    }
    finally{
      await conn.close();
    }
  }
}

class Dashboard{
  final int participantId; 
  final int quizId;
  final int participantScore;
  final int questionTotal;

  Dashboard({required this.participantId, required this.quizId, required this.participantScore, required this.questionTotal});

  Future<void> insert() async {
    var conn = await MySqlConnection.connect(settings);

    try{
      var result = await conn.query(
        'INSERT INTO dashboard (participant_id, quiz_id, participant_score, question_total) VALUES (?, ?, ?, ?)', 
        [participantId, quizId, participantScore, questionTotal]);
      print('Inserted dashboard record: ${result.insertId}');
    } catch (e) {
      print('Failed to insert dashboard record: $e');
    } finally {
      await conn.close();
    }
  }
}