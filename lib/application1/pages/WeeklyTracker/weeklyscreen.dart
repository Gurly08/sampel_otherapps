import 'package:flutter/material.dart';
import '../../models/expanses_models.dart';
import '../../provider/expense_provider.dart';
import '../DailyExpenses/shopping_tracker.dart';
import '../MonthlyTracker/monthscreen.dart';
import 'inputweekly.dart';

class Weeklyscreen extends StatefulWidget {
  const Weeklyscreen({super.key});

  @override
  State<Weeklyscreen> createState() => _WeeklyscreenState();
}

class _WeeklyscreenState extends State<Weeklyscreen> {
  List<Expense> weeklyExpenses = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWeeklyExpenses();
  }

  void _loadWeeklyExpenses() {
    final expenseProvider = ExpenseProvider.of(context);
    if (expenseProvider != null) {
      setState(() {
        weeklyExpenses = expenseProvider.expenses.where((e) => e.isWeekly).toList();
      });
    }
  }

  void _deleteExpense(Expense expense) {
    final expenseProvider = ExpenseProvider.of(context);
    if (expenseProvider != null) {
      setState(() {
        expenseProvider.removeExpense(expense);
        _loadWeeklyExpenses();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: SizedBox(
        width: 220,
        child: Drawer(
          child: ListView(
            children: [
              const SizedBox(
                height: 55,
                child: DrawerHeader(
                  curve: Curves.linear,
                  child: Text('Shopping Tracker Indonesia'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Daily Expenses'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShoppingTracker()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Weekly Expenses'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Monthly Expenses'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Monthscreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Weekly Expenses'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 360,
              height: 260,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Track your weekly expenses here!',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: weeklyExpenses.isEmpty
                  ? const Center(child: Text('Tidak ada pengeluaran mingguan.'))
                  : ListView.builder(
                      itemCount: weeklyExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = weeklyExpenses[index];
                        final totalAmount = expense.linkedDailyExpenses.fold(0, (sum, item) {
                          return sum + (item.details.fold(0, (subSum, detail) {
                            return subSum + (detail['amount'] is int ? detail['amount'] as int : 0);
                          }));
                        });

                        return Card(
                          color: expense.color,
                          child: ListTile(
                            title: Text(expense.title),
                            subtitle: Text('${expense.weekCategory} - ${expense.monthYear}'),
                            trailing: Text('Rp $totalAmount'),
                            onTap: () async {
                              final updatedExpense = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InputWeekly(expense: expense),
                                ),
                              );
                              if (updatedExpense != null) {
                                _loadWeeklyExpenses();
                              }
                            },
                            onLongPress: () => _deleteExpense(expense),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newWeeklyExpense = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InputWeekly()),
          );

          if (newWeeklyExpense != null) {
            final expenseProvider = ExpenseProvider.of(context);
            if (expenseProvider != null) {
              setState(() {
                expenseProvider.addExpense(newWeeklyExpense);
                _loadWeeklyExpenses();
              });
            }
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
