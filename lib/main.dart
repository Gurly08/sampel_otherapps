import 'package:flutter/material.dart';
import 'package:sampel_otherapps/application1/pages/DailyExpenses/shopping_tracker.dart';
import 'package:sampel_otherapps/application1/provider/expense_provider.dart';
import 'package:sampel_otherapps/application1/models/expanses_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Expense> expenses = [];

  void addExpense(Expense expense) {
    setState(() {
      expenses.add(expense);
    });
  }

  void removeExpense(Expense expense) {
    setState(() {
      expenses.remove(expense);
    });
  }

  void updateExpense(int index, Expense updatedExpense) {
    setState(() {
      expenses[index] = updatedExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpenseProvider(
      expenses: expenses,
      addExpense: addExpense,
      removeExpense: removeExpense,
      updateExpense: updateExpense,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ShoppingTracker(),
      ),
    );
  }
}
