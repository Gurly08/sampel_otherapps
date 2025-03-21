import 'package:flutter/material.dart';

class Expense {
  final String id;
  final String title;
  final DateTime date;
  final Color color;
  final String weekCategory; 
  final String monthYear; 
  final bool isWeekly; 
  final String? weekId;
  final List<Expense> linkedDailyExpenses; 
  final List<Map<String, dynamic>> details;

  Expense({
    required this.id,
    required this.title,
    required this.date,
    required this.color,
    required this.weekCategory,
    required this.monthYear,
    this.isWeekly = false,
    this.weekId,
    this.linkedDailyExpenses = const [],
    this.details = const [],
  });

  
  factory Expense.createWeeklyExpense({
    required String title,
    required DateTime date,
    required Color color,
    required String weekCategory,
    required List<Expense> dailyExpenses,
  }) {
    String monthYear = "${date.year}-${date.month.toString().padLeft(2, '0')}";
    String weekId = "$monthYear-$weekCategory";

    return Expense(
      id: weekId,
      title: title,
      date: date,
      color: color,
      weekCategory: weekCategory,
      monthYear: monthYear,
      isWeekly: true,
      weekId: weekId,
      linkedDailyExpenses: dailyExpenses,
    );
  }
}
