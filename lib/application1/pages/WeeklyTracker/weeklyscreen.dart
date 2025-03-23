import 'package:flutter/material.dart';
import '../../provider/expense_provider.dart';
import '../DailyExpenses/shopping_tracker.dart';
import '../MonthlyTracker/monthscreen.dart';

class Weeklyscreen extends StatelessWidget {
  const Weeklyscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = ExpenseProvider.of(context);
    final allExpenses = expenseProvider?.expenses ?? [];

    // 🔥 Mengambil hanya Weekly Expenses
    final weeklyExpenses = allExpenses.where((expense) => expense.isWeekly).toList();

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
            // Banner
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
            // List of Weekly Expenses
            Expanded(
              child: weeklyExpenses.isEmpty
                  ? const Center(child: Text('Tidak ada pengeluaran mingguan.'))
                  : ListView.builder(
                      itemCount: weeklyExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = weeklyExpenses[index];

                        return Card(
                          color: expense.color,
                          child: ListTile(
                            title: Text(expense.title),
                            subtitle: Text('${expense.weekCategory} - ${expense.monthYear}'),
                            trailing: Text(
                              'Rp ${expense.linkedDailyExpenses.fold(0, (sum, item) => sum + item.details.fold(0, (subSum, detail) => subSum + (detail['amount'] as int)))}',
                            ),
                            onTap: () {
                              // TODO: Navigasi ke detail weekly expense
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigasi ke form input weekly expense
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
