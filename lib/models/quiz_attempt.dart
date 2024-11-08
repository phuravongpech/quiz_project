import 'quiz.dart';

class QuizAttempt {
  final int _id;
  final Quiz _quiz;
  final Map<int, List<int>> _userAnswers;
  int score = 0;

  QuizAttempt(
      {required int id, required Quiz quiz, required Map<int, List<int>> userAnswers})
      : _id = id,
        _quiz = quiz,
        _userAnswers = userAnswers;

  get id => _id;
  get quiz => _quiz;
  get userAnswers => _userAnswers;


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