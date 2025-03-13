class Expense {
  final String id;
  final String title;
  final DateTime date;
  final List<Map<String, dynamic>> details;

  Expense({
    required this.id,
    required this.title,
    required this.date,
    required this.details,
  });
}
