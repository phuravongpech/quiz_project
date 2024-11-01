

import 'quiz.dart';
import 'answer.dart';
import 'quiz_attempt.dart';
void main() {
  // print("Enter quiz title:");
  // String quizTitle = stdin.readLineSync()!;

  // Quiz quiz = Quiz(title: quizTitle, questions: []);

  // while (true) {
  //   print("Enter question title (or 'q' to quit):");
  //   String questionTitle = stdin.readLineSync()!;
  //   if (questionTitle.toLowerCase() == 'q') {
  //     break;
  //   }

  //   print("Enter question type (singleQuestion or multipleQuestion):");
  //   String questionTypeStr = stdin.readLineSync()!;
  //   QuestionType questionType = questionTypeStr == "singleQuestion"
  //       ? QuestionType.singleQuestion
  //       : QuestionType.multipleQuestion;

  //   Question question = Question(
  //     id: quiz.questions!.length + 1, // Assuming IDs start from 1
  //     quizId: 1, // Adjust as needed
  //     title: questionTitle,
  //     questionType: questionType,
  //     answers: [],
  //   );

  //   while (true) {
  //     print("Enter answer text (or 'q' to quit):");
  //     String answerText = stdin.readLineSync()!;
  //     if (answerText.toLowerCase() == 'q') {
  //       break;
  //     }

  //     print("Is the answer correct? (true/false):");
  //     String isCorrectStr = stdin.readLineSync()!;
  //     bool isCorrect = isCorrectStr.toLowerCase() == "true";

  //     question.addAnswer(Answer(
  //       id: question.answers!.length + 1, // Assuming IDs start from 1
  //       text: answerText,
  //       isCorrect: isCorrect,
  //     ));
  //   }

  //   quiz.addQuestion(question);
  // }

  // Now you have the `quiz` object with all the inputted questions and answers
  // print(quiz); // You can print or process the quiz object as needed
  Question ques1 = Question(
      id: 1,
      quizId: 1,
      title: "what is my name",
      questionType: QuestionType.singleQuestion,
      answerChoices: [
        Answer(id: 1, text: "vong1", isCorrect: true),
        Answer(id: 2, text: "vong2", isCorrect: false),
        Answer(id: 3, text: "vong3", isCorrect: false),
        Answer(id: 4, text: "vong4", isCorrect: false),
      ],
      correctAnswers: [
        0
      ]);

  Question ques2 = Question(
      id: 2,
      quizId: 1,
      title: "what is my gf name",
      questionType: QuestionType.multipleQuestion,
      answerChoices: [
        Answer(id: 1, text: "montha1", isCorrect: false),
        Answer(id: 2, text: "montha2", isCorrect: false),
        Answer(id: 3, text: "montha3", isCorrect: false),
        Answer(id: 4, text: "montha4", isCorrect: false),
      ],
      correctAnswers: [
        0,
        1,
        2
      ]);
  Quiz q1 = Quiz(id: 1, title: "code", questions: [ques1, ques2]);

  

  // q1.addQuestion(ques1);
  // q1.addQuestion(ques2);
  print(q1);

  QuizAttempt attempt1 = QuizAttempt(id: 1, quiz: q1, userAnswers: {
    1: [0],
    2: [0, 1, 2]
  });

  attempt1.calculateScore();

  print(attempt1.score);
}



enum QuestionType { singleQuestion, multipleQuestion }

class Question {
  final int id;
  final int quizId;
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
}







//create a QuizApp clsass
//create list of quizzes objects
//also participant and quiz attempts initailize
//prompt user to pick between 4 choices

// 1.create quiz
// createQuiz() to create quizzes and save it 

// 2. list all quizzes
// listQuiz()

// 3.takeQuiz()
// ask user to pick the quiz and take the quiz

// 4.listAttempts()
// attempt with score

// 5.exit return

//then save to database
