import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sampel_otherapps/application1/pages/WeeklyTracker/weeklyscreen.dart';
import '../../models/expanses_models.dart';
import '../../provider/expense_provider.dart';
import '../MonthlyTracker/monthscreen.dart';
import 'detail_item.dart';
import 'input.dart';

class ShoppingTracker extends StatefulWidget {
  const ShoppingTracker({super.key});

  @override
  State<ShoppingTracker> createState() => _ShoppingTrackerState();
}

class _ShoppingTrackerState extends State<ShoppingTracker> {
  void _removeExpense(int index) {
    final provider = ExpenseProvider.of(context);
    if (provider == null) return;

    final expense = provider.expenses[index];
    provider.removeExpense(expense);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense Deleted!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              provider.addExpense(expense);
            });
          },
        ),
      ),
    );
    setState(() {});
  }


  double _calculateTotalExpense(Expense expense) {
    return expense.details.fold<double>(0, (sum, item) => sum + (item['quantity'] * item['amount']));
  }

  @override
  Widget build(BuildContext context) {
    final provider = ExpenseProvider.of(context);
    if (provider == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final expenses = provider.expenses;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expenses'), 
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
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
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Weekly Expenses'),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const Weeklyscreen()),
                  );
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Shopping Tracker Banner',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Daily Shopping List'),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 15),
            Expanded(
              child: expenses.isEmpty
                  ? const Center(child: Text("Tidak ada Pengeluaran"))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: expenses.length,
                      itemBuilder: (ctx, index) {
                        double totalExpense = _calculateTotalExpense(expenses[index]);
                        return Dismissible(
                          key: Key(expenses[index].id),
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) {
                            setState(() {
                              _removeExpense(index);
                            });
                          },
                          background: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          secondaryBackground: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          child: SizedBox(
                            width: 160,
                            height: 180,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: expenses[index].color,
                              child: InkWell(
                                onTap: () async {
                                  final updatedExpense = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        expense: expenses[index],
                                        onUpdate: (updatedExpense) {
                                          setState(() {
                                            provider.updateExpense(index, updatedExpense);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                  if (updatedExpense != null) {
                                    setState(() {
                                      provider.updateExpense(index, updatedExpense);
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        expenses[index].title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Rp ${NumberFormat('#,###').format(totalExpense)}'),
                                      const SizedBox(height: 20),
                                      Text(expenses[index].weekCategory),
                                      Text(
                                        DateFormat('yyyy-MM-dd').format(expenses[index].date),
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 153, 207, 252),
        hoverColor: Colors.blueAccent,
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InputScreen()),
          );

          if (newExpense != null) {
            setState(() {
              provider.addExpense(newExpense);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
