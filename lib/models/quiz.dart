import 'question.dart';

class Quiz {
  final int id;
  final String title;
  List<Question> questions; 

  Quiz({required this.id, required this.title,required this.questions});

  void addQuestion(Question question) {
    questions.add(question);
  }

  @override
  String toString() {
    return 'Quiz: $title\nQuestions:\n${questions.map((q) => q.toString()).join('\n')}\n';
  }
}