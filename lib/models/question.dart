import 'package:mysql1/mysql1.dart';
import 'package:quiz_project/database.dart';
import 'quiz.dart';
import 'answer.dart';

enum QuestionType {
  singleQuestion(1),
  multipleQuestion(2);

  final int value;
  const QuestionType(this.value);

  static QuestionType fromValue(int value) {
    return QuestionType.values.firstWhere((type) => type.value == value);
  }
}

class Question {
  final int id;
  int quizId;
  final String title;
  final QuestionType questionType;
  final List<Answer>? answerChoices;
  final List<int> correctAnswers;
  Quiz? quiz;

  Question(
      {required this.id,
      required this.quizId,
      required this.title,
      required this.questionType,
      required this.answerChoices,
      required this.correctAnswers,
      this.quiz});

  void addAnswer(Answer answer) {
    answerChoices!.add(answer);
  }

  @override
  String toString() {
    return '  - $title (${questionType == QuestionType.singleQuestion ? 'Single Choice' : 'Multiple Choice'})\n    Answers:\n${answerChoices!.map((a) => '      ${a.toString()}').join('\n')}\n    Correct Answers: ${correctAnswers.map((i) => answerChoices![i].text).join(', ')}';
  }

  //function to check if user selected answer (a list of int) is correct to the correct answers list of int
  bool isAnswerCorrect(List<int> userSelectedAnswer) {
    if (questionType == QuestionType.singleQuestion) {
      return userSelectedAnswer.length == 1 &&
          userSelectedAnswer.first == correctAnswers.first;
    } else {
      return Set<int>.from(correctAnswers).containsAll(userSelectedAnswer) &&
          Set<int>.from(userSelectedAnswer).containsAll(correctAnswers);
    }
  }

  Future<void> insert() async{
    var conn = await MySqlConnection.connect(settings);
    try{
      var result = await conn.query('INSERT INTO question(question_text, quiz_id, question_type) VALUES (?,?,?)', [title, quizId, questionType.value]);
      int questionId = result.insertId!;

      for (var answer in answerChoices!) {
        final newAnswer = Answer(
          id: 0, //Auto_Increment
          questionId: questionId,
          text: answer.text,
          isCorrect: answer.isCorrect
        );
        await newAnswer.insert();
      }
    }
    catch(e){
      print(e);
      throw Exception('Failed to insert question : $e');
    }
    finally{
      await conn.close();
    }
  }

  static Future<List<Question>> getByQuizId(int quizId) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn.query(
        'SELECT id, question_text, quiz_id, question_type FROM question WHERE quiz_id = ?',
        [quizId]
      );
      
      List<Question> questions = [];
      for (var row in results) {
        var answers = await Answer.getByQuestionId(row['id']);
        var question = Question(
          id: row['id'],
          quizId: row['quiz_id'],
          title: row['question_text'],
          questionType: QuestionType.fromValue(row['question_type']),
          answerChoices: answers,
          correctAnswers: answers
            .asMap()
            .entries
            .where((entry) => entry.value.isCorrect)
            .map((entry) => entry.key)
            .toList()
        );
        questions.add(question);
      }
      return questions;
    } catch (e) {
      print('Failed to get questions: $e');
      throw Exception('Failed to get questions');
    }
  }

}

