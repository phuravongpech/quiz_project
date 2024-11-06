import 'dart:io';

import 'package:quiz_project/models/answer.dart';
import 'package:quiz_project/models/question.dart';
import 'package:quiz_project/models/quiz.dart';

Future<void> createQuiz() async {
  stdout.write('Enter quiz title: ');
  String? quizTitle = stdin.readLineSync();

  List<Question> questions = [];

  while (true) {
    stdout.write('Enter question title: ');
    String? questionTitle = stdin.readLineSync();

    int questionType;
    while (true) {
      stdout.write('Enter question type (1 for Single Choice, 2 for Multiple Choice): ');
      questionType = int.parse(stdin.readLineSync()!);
      if (questionType == 1 || questionType == 2) {
        break;
      } else {
        print('Invalid input. Please choose 1 for Single Choice or 2 for Multiple Choice.');
      }
    }

    List<Answer> answers = [];
    bool hasCorrectAnswer = false;
    int correctCount = 0;

    while (true) {
      stdout.write('Enter answer text: ');
      String? answerText = stdin.readLineSync();
      
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
        if(isCorrect) correctCount++;
      }

      answers.add(Answer(
        id: 0,
        questionId: 0,
        text: answerText!,
        isCorrect: isCorrect,
      ));

      stdout.write('Add another answer? (y/n): ');
      if (stdin.readLineSync()!.toLowerCase() != 'y') break;
    }

    if(questionType == 1 && correctCount == 0){
      print("Single choice must have at least one correct answer.");
      continue;
    }
    else if(questionType == 2 && (correctCount < 2 || answers.length - correctCount < 1)){
      print("Multiple choice must have at least two correct answer and one incorrect");
      continue;
    }

    List<int> correctAnswers = [];
    for (int i = 0; i < answers.length; i++) {
      if (answers[i].isCorrect) correctAnswers.add(i);
    }

    questions.add(Question(
      id: 0,
      quizId: 0,
      title: questionTitle!,
      questionType: QuestionType.fromValue(questionType),
      answerChoices: answers,
      correctAnswers: correctAnswers,
    ));

    stdout.write('Add another question? (y/n): ');
    if (stdin.readLineSync()!.toLowerCase() != 'y') break;
  }

  Quiz quiz = Quiz(id: 0, title: quizTitle!, questions: questions);
  await quiz.insert();
  print('quiz "$quizTitle" created success');
}
