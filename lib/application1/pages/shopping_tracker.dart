import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expanses_models.dart';
import 'detail_item.dart';
import 'input.dart';

class ShoppingTracker extends StatefulWidget {
  const ShoppingTracker({super.key});

  @override
  State<ShoppingTracker> createState() => _ShoppingTrackerState();
}

class _ShoppingTrackerState extends State<ShoppingTracker> {
  List<Expense> expenses = [];

  void _addExpense(Expense expense) {
    setState(() {
      expenses.add(expense);
    });
  }

  void _editExpense(int index) async {
    final updatedExpense = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputScreen(expense: expenses[index]),
      ),
    );
    if (updatedExpense != null) {
      setState(() {
        expenses[index] = updatedExpense;
      });
    }
  }

  void _deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  void _updateExpense(int index, Expense updatedExpense) {
    setState(() {
      expenses[index] = updatedExpense;
    });
  }

  void _removeExpense(int index) {
    final expense = expenses[index];
    setState(() {
      expenses.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense Deleted!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              expenses.insert(index, expense);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: expenses.isEmpty
          ? const Center(child: Text("Tidak ada Pengeluaran"))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (ctx, index) {
                return Dismissible(
                  key: Key(expenses[index].title),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    _removeExpense(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(expenses[index].title),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(expenses[index].date)),
                      onTap: () async {
                        final updatedExpense = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              expense: expenses[index],
                              onUpdate: (updatedExpense) {
                                _updateExpense(index, updatedExpense);
                              },
                            ),
                          ),
                        );
                        if (updatedExpense != null) {
                          _updateExpense(index, updatedExpense);
                        }
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editExpense(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExpense(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InputScreen()),
          );
          if (newExpense != null) {
            _addExpense(newExpense);
          }
        },
      ),
    );
  }
}
