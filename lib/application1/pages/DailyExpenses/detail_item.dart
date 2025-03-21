import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expanses_models.dart';
import 'input.dart';

class DetailScreen extends StatefulWidget {
  final Expense expense;
  final Function(Expense) onUpdate;

  const DetailScreen({super.key, required this.expense, required this.onUpdate});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Expense expense;

  @override
  void initState() {
    super.initState();
    expense = widget.expense;
  }

  void _editExpense() async {
    final updatedExpense = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputScreen(expense: expense),
      ),
    );
    if (updatedExpense != null && updatedExpense is Expense) {
      setState(() {
        expense = updatedExpense;
      });
      widget.onUpdate(updatedExpense);
    }
  }

  void _deleteExpenseItem(int index) {
    setState(() {
      List<Map<String, dynamic>> updatedDetails = List.from(expense.details);
      updatedDetails.removeAt(index);
      expense = Expense(
        id: expense.id,
        title: expense.title,
        date: expense.date,
        color: expense.color,
        weekCategory: expense.weekCategory,
        monthYear: expense.monthYear,
        isWeekly: expense.isWeekly,
        weekId: expense.weekId,
        linkedDailyExpenses: expense.linkedDailyExpenses,
        details: updatedDetails,
      );
    });
    widget.onUpdate(expense);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(expense.title),
        backgroundColor: expense.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editExpense,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('yyyy-MM-dd').format(expense.date)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: const [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                ...expense.details.asMap().entries.map((entry) {
                  int index = entry.key;
                  var detail = entry.value;
                  double total = detail['quantity'] * detail['amount'];
                  return TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(detail['name'])),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(detail['quantity'].toString())),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('Rp ${NumberFormat('#,###').format(detail['amount'])}')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('Rp ${NumberFormat('#,###').format(total)}')),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteExpenseItem(index),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            const Divider(),
            ListTile(
              title: const Text('Total'),
              trailing: Text(
                'Rp ${NumberFormat('#,###').format(expense.details.fold<double>(0, (sum, item) => sum + (item['quantity'] * item['amount'])))}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
