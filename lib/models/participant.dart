class Participant {
  final int id;
  final String firstName;
  final String lastName;

  Participant(
      {required this.id, required this.firstName, required this.lastName});

  String get fullName => '$firstName $lastName';

}