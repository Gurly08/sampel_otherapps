import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expanses_models.dart';

class InputScreen extends StatefulWidget {
  final Expense? expense;

  const InputScreen({super.key, this.expense});

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _titleController = TextEditingController();
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _amountControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      for (var detail in widget.expense!.details) {
        _nameControllers.add(TextEditingController(text: detail['name']));
        _quantityControllers.add(TextEditingController(text: detail['quantity'].toString()));
        _amountControllers.add(TextEditingController(text: detail['amount'].toString()));
      }
    } else {
      _addExpenseField();
    }
  }

  void _addExpenseField() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _quantityControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
    });
  }

  void _removeExpenseField(int index) {
    setState(() {
      _nameControllers.removeAt(index);
      _quantityControllers.removeAt(index);
      _amountControllers.removeAt(index);
    });
  }

  void _submitData() {
    if (_titleController.text.isEmpty ||
        _nameControllers.any((ctrl) => ctrl.text.isEmpty) ||
        _quantityControllers.any((ctrl) => ctrl.text.isEmpty) ||
        _amountControllers.any((ctrl) => ctrl.text.isEmpty)) {
      return;
    }

    final newExpense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      title: _titleController.text,
      date: DateTime.now(),
      details: List.generate(
        _nameControllers.length,
        (index) => {
          'name': _nameControllers[index].text,
          'quantity': int.parse(_quantityControllers[index].text),
          'amount': double.parse(_amountControllers[index].text),
        },
      ),
    );

    Navigator.pop(context, newExpense);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Expense')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Expense Title'),
            ),
            ...List.generate(_nameControllers.length, (index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _nameControllers[index],
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _quantityControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Qty'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Unit Price'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeExpenseField(index),
                  ),
                ],
              );
            }),
            const SizedBox(height: 25),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _addExpenseField,
                  child: const Text('Add Expense'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _submitData,
                  child: const Text('Save Expense'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
