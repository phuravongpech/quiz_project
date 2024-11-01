class Answer {
  final int id;
  final String text;
  final bool isCorrect;
  bool isSelected;

  Answer(
      {required this.id,
      required this.text,
      required this.isCorrect,
      this.isSelected = false});

  set selected(bool isSelected) => this.isSelected = true;
  set deselected(bool isSelected) => this.isSelected = false;

  @override
  String toString() {
    return '$text${isCorrect ? ' (Correct)' : ''}';
  }
}
