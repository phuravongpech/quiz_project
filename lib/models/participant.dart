import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';

class Participant {
  final int id;
  final String firstName;
  final String lastName;

  Participant(
      {required this.id, required this.firstName, required this.lastName});

  String get fullName => '$firstName $lastName';

  Future<void> insert() async{
    var conn = await MySqlConnection.connect(settings);
    try{
      await conn.query('INSERT INTO participant(name) VALUES (?)', [fullName]);
    }
    catch(e){
      print(e);
      throw Exception('Failed to insert participant: $e');
    }
    finally{
      await conn.close();
    }
  }
  
}