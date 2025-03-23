import 'package:flutter/material.dart';
import '../models/expanses_models.dart';

class ExpenseProvider extends InheritedWidget {
  final List<Expense> expenses;
  final Function(Expense) addExpense;
  final Function(Expense) removeExpense;
  final Function(int, Expense) updateExpense;

  const ExpenseProvider({
    Key? key,
    required Widget child,
    required this.expenses,
    required this.addExpense,
    required this.removeExpense,
    required this.updateExpense,
  }) : super(key: key, child: child);

  static ExpenseProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ExpenseProvider>();
  }

  @override
  bool updateShouldNotify(ExpenseProvider oldWidget) {
    return oldWidget.expenses != expenses;
  }
}
