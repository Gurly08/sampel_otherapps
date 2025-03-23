import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/expanses_models.dart';

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
  DateTime? _selectedDate;
  Color _selectedColor = const Color(0xffA3F7BF);
  String _selectedWeekCategory = 'WeekOne';

  final List<Color> colors = const [
    Color(0xffA3F7BF),
    Color(0xffFEFF9A),
    Color(0xffFDDEDE),
    Color(0xff9BF4D5),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _selectedDate = widget.expense!.date;
      _selectedColor = widget.expense!.color;
      _selectedWeekCategory = widget.expense!.weekCategory;
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

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitData() {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      return;
    }

    final newExpense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      title: _titleController.text,
      date: _selectedDate!,
      color: _selectedColor,
      weekCategory: _selectedWeekCategory,
      monthYear: "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}",
      details: List.generate(
        _nameControllers.length,
        (index) => {
          'name': _nameControllers[index].text,
          'quantity': int.tryParse(_quantityControllers[index].text) ?? 0,
          'amount': double.tryParse(_amountControllers[index].text) ?? 0.0,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Card Color:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(width: 1, color: Colors.black)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No Date Chosen!'
                          : 'Picked Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text('Choose Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedWeekCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedWeekCategory = newValue!;
                  });
                },
                items: ['WeekOne', 'WeekTwo', 'WeekThree', 'WeekFour'].map((week) {
                  return DropdownMenuItem(
                    value: week,
                    child: Text(week),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Expense Title'),
              ),
              const SizedBox(height: 15),
              ...List.generate(_nameControllers.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameControllers[index],
                        decoration: const InputDecoration(labelText: 'Item Name'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _quantityControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Qty'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _amountControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price Unit'),
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
              ),
              const SizedBox(height: 25),
              const Text('Catatan: \n Setiap catatan pengeluaran memiliki kategori mingguan dari tanggal pengeluaran yang dipilih'),
              const Text('Week 1: 1-7 \nWeek 2: 8-14 \nWeek 3: 14-21 \nWeek 4: 22 - 31/28 '),
              const Text('Category ini berfungsi agar setiap pengeluaran perbulan dapat di analisa, dari minggu berapa yang memiliki pengeluaran tertinggi.')
            ],
          ),
        ),
      ),
    );
  }
}
