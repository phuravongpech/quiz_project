import 'dart:io';
import 'package:quiz_project/controllers/create_quiz.dart';
import 'package:quiz_project/controllers/view_dashboard.dart';
import 'package:quiz_project/controllers/take_quiz.dart';

void main() async {
  while (true) {
    print('Welcome to the Quiz App!');
    print('1. Create Quiz');
    print('2. Take Quiz');
    print('3. Show Your Score');
    print('4. Exit');
    stdout.write('Choose an option (1-4): ');
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await createQuiz();
        break;
      case '2':
        await takeQuiz();
        break;
      case '3':
        await viewDashboard();
        break;
      case '4':
        print('Exiting...');
        exit(0);
      default:
        print('Invalid option. Please choose 1, 2, 3, or 4.');
    }
  }
}
