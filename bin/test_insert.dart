import 'package:quiz_project/models/participant.dart';
import 'package:quiz_project/models/quiz.dart';
import 'package:quiz_project/models/question.dart';
import 'package:quiz_project/models/answer.dart';

Future<void> main() async {
  // Test inserting a participant
  final participant = Participant(id: 1, firstName: 'John', lastName: 'Doe');
  await participant.insert();
  print('Inserted participant: ${participant.fullName}');

  // Test inserting a quiz
  final quiz = Quiz(id: 1, title: 'Sample Quiz', questions: []);

  // Create some sample answers
  final answers = [
    Answer(id: 1, questionId: 0, text: 'Answer A', isCorrect: true),
    Answer(id: 2, questionId: 0, text: 'Answer B', isCorrect: false),
    Answer(id: 3, questionId: 0, text: 'Answer C', isCorrect: false),
  ];

  // Create a sample question
  final question = Question(
    id: 1,
    quizId: 1,
    title: 'What is the capital of France?',
    questionType: QuestionType.singleQuestion,
    answerChoices: answers,
    correctAnswers: [0], // Index of the correct answer
  );

  // Add the question to the quiz
  quiz.addQuestion(question);

  // Insert the quiz
  await quiz.insert();
  print('Inserted quiz: ${quiz.title}');

}

