import 'quiz.dart';

class QuizAttempt {
  final int id;
  final Quiz quiz;
  final Map<int, List<int>> userAnswers;
  int score = 0;

  QuizAttempt(
      {required this.id, required this.quiz, required this.userAnswers});

  //calculate total score of the quiz attempt
  void calculateScore() {
    score = 0;
    for (var question in quiz.questions) {
      if (question.isAnswerCorrect(userAnswers[question.id] ?? [])) {
        score += 1;
      }
    }
  }
}