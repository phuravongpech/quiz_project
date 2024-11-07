import 'dart:io';

import 'package:quiz_project/models/answer.dart';
import 'package:quiz_project/models/question.dart';
import 'package:quiz_project/models/quiz.dart';

Future<void> createQuiz() async {
  stdout.write('Enter quiz title: ');
  String? quizTitle = stdin.readLineSync();

  if (quizTitle == null || quizTitle.isEmpty) {
    print("quiz title cannot be empty.");
    return;
  }

  List<Question> questions = [];

  while (true) {
    stdout.write('Enter question title: ');
    String? questionTitle = stdin.readLineSync();

    if (questionTitle == null || questionTitle.isEmpty) {
      print("Question title cannot be empty.");
      continue;
    }

    int questionType;
    while (true) {
      stdout.write('Enter question type (1 for Single Choice, 2 for Multiple Choice): ');
      try {
        questionType = int.parse(stdin.readLineSync()!);
        if (questionType == 1 || questionType == 2) break;
      } catch (e) {
        print('Invalid input.');
      }
    }

    List<Answer> answers = [];
    bool hasCorrectAnswer = false;
    int correctCount = 0;

    while (true) {
      stdout.write('Enter answer text: ');
      String? answerText = stdin.readLineSync();

      if (answerText == null || answerText.isEmpty) {
        print("Answer text cannot be empty.");
        continue;
      }

      bool isCorrect = false;

      if (questionType == 1) {
        stdout.write('Is this the correct answer? (y/n): ');
        isCorrect = stdin.readLineSync()!.toLowerCase() == 'y';

        if (isCorrect && hasCorrectAnswer) {
          print('Error: Single Choice question can have only one correct answer.');
          continue;
        } else if (isCorrect) {
          hasCorrectAnswer = true;
        }
      } else if (questionType == 2) {
        stdout.write('Is this answer correct? (y/n): ');
        isCorrect = stdin.readLineSync()!.toLowerCase() == 'y';
        if (isCorrect) correctCount++;
      }

      answers.add(Answer(
        id: 0,
        questionId: 0,
        text: answerText,
        isCorrect: isCorrect,
      ));

      stdout.write('Add another answer? (y/n): ');
      if (stdin.readLineSync()!.toLowerCase() != 'y') break;
    }

    if (questionType == 1 && !hasCorrectAnswer) {
      print("Error: Single choice question must have exactly one correct answer.");
      continue;
    } else if (questionType == 2) {
      if (correctCount < 2) {
        print("Error: Multiple choice questions must have at least two correct answers.");
        continue;
      }
      if (answers.length - correctCount < 1) {
        print("Error: Multiple choice questions must have at least one incorrect answer.");
        continue;
      }
    }

    List<int> correctAnswers = [];
    for (int i = 0; i < answers.length; i++) {
      if (answers[i].isCorrect) correctAnswers.add(i);
    }

    questions.add(Question(
      id: 0,
      quizId: 0,
      title: questionTitle,
      questionType: QuestionType.fromValue(questionType),
      answerChoices: answers,
      correctAnswers: correctAnswers,
    ));

    stdout.write('Add another question? (y/n): ');
    if (stdin.readLineSync()!.toLowerCase() != 'y') break;
  }

  Quiz quiz = Quiz(id: 0, title: quizTitle, questions: questions);
  await quiz.insert();
  print('Quiz "$quizTitle" created successfully.');
}
