import 'package:quiz_project/quiz_project.dart';

void main() async {
  Participant participant = Participant('Seii ke');
  await participant.insert();

  Dashboard dashboard = Dashboard(
    participantId: 1,
    quizId: 1,
    participantScore: 80,
    questionTotal: 100,
  );
  await dashboard.insert();
}
