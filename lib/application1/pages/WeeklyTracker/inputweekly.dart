import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/expanses_models.dart';
import '../../provider/expense_provider.dart';


class InputWeekly extends StatefulWidget {
  final Expense? expense;

  const InputWeekly({super.key, this.expense});

  @override
  State<InputWeekly> createState() => _InputWeeklyState();
}

class _InputWeeklyState extends State<InputWeekly> {
  final TextEditingController _titleController = TextEditingController();
  Color _selectedColor = const Color(0xffA3F7BF);
  String _selectedMonth = 'Januari';
  String _selectedWeekCategory = 'WeekOne';
  List<Expense> selectedDailyExpenses = [];
  List<Expense> dailyExpenses = [];

  final List<Color> colors = const [
    Color(0xffA3F7BF),
    Color(0xffFEFF9A),
    Color(0xffFDDEDE),
    Color(0xff9BF4D5),
  ];
  final List<String> months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> weekCategories = ['WeekOne', 'WeekTwo', 'WeekThree', 'WeekFour'];

  @override
void initState() {
  super.initState();
  if (widget.expense != null) {
    _titleController.text = widget.expense!.title;
    _selectedColor = widget.expense!.color;
    _selectedWeekCategory = widget.expense!.weekCategory;
    selectedDailyExpenses = List.from(widget.expense!.linkedDailyExpenses);
  }
}

/// *Pindahkan pemanggilan ExpenseProvider ke didChangeDependencies()*
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _filterDailyExpenses();
}

void _filterDailyExpenses() {
  final expenseProvider = ExpenseProvider.of(context);
  setState(() {
    dailyExpenses = expenseProvider?.expenses
            .where((expense) => expense.weekCategory == _selectedWeekCategory)
            .toList() ??
        [];
  });
}

void _saveWeeklyExpense() {
  String id = widget.expense?.id ?? const Uuid().v4();
  String monthYear = "2025-${(months.indexOf(_selectedMonth) + 1).toString().padLeft(2, '0')}";

  final newWeeklyExpense = Expense(
    id: id,
    title: _titleController.text,
    date: DateTime.now(),
    color: _selectedColor,
    weekCategory: _selectedWeekCategory,
    linkedDailyExpenses: selectedDailyExpenses,
    monthYear: monthYear,
    isWeekly: true,
  );

  final expenseProvider = ExpenseProvider.of(context);
  if (widget.expense == null) {
    expenseProvider?.addExpense(newWeeklyExpense);
  } else {
    final index = expenseProvider?.expenses.indexWhere((e) => e.id == widget.expense?.id);
    if (index != null && index != -1) {
      expenseProvider?.updateExpense(index, newWeeklyExpense);
    }
  }
  Navigator.pop(context);
}


  void _toggleExpenseSelection(Expense expense) {
    setState(() {
      if (selectedDailyExpenses.contains(expense)) {
        selectedDailyExpenses.remove(expense);
      } else {
        selectedDailyExpenses.add(expense);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Weekly Expense' : 'Edit Weekly Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Warna Card:'),
              Wrap(
                spacing: 8,
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color ? Border.all(width: 2, color: Colors.black) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Pengeluaran'),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedMonth,
                onChanged: (newValue) {
                  setState(() => _selectedMonth = newValue!);
                  _filterDailyExpenses();
                },
                items: months.map((month) {
                  return DropdownMenuItem(value: month, child: Text(month));
                }).toList(),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedWeekCategory,
                onChanged: (newValue) {
                  setState(() => _selectedWeekCategory = newValue!);
                  _filterDailyExpenses();
                },
                items: weekCategories.map((week) {
                  return DropdownMenuItem(value: week, child: Text(week));
                }).toList(),
              ),
              const SizedBox(height: 10),
              Text('Pilih Daily Expenses (Total Dipilih: ${selectedDailyExpenses.length}):'),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: dailyExpenses.length,
                itemBuilder: (context, index) {
                  final expense = dailyExpenses[index];
                  final isSelected = selectedDailyExpenses.contains(expense);

                  return GestureDetector(
                    onTap: () => _toggleExpenseSelection(expense),
                    child: Card(
                      color: isSelected ? Colors.green.withOpacity(0.7) : Colors.white,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(DateFormat.yMMMd().format(expense.date)),
                            if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWeeklyExpense,
                child: const Text('Save Week Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}