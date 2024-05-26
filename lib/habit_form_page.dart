import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'habit.dart';

class HabitFormPage extends StatefulWidget {
  @override
  _HabitFormPageState createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  List<String> _frequency = [];
  TimeOfDay _reminderTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Habit')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Habit Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Frequency (e.g., MWF)'),
                onSaved: (value) {
                  _frequency = value!.split(',');
                },
              ),
              ListTile(
                title: Text('Reminder Time: ${_reminderTime.format(context)}'),
                trailing: Icon(Icons.timer),
                onTap: _pickTime,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Provider.of<HabitProvider>(context, listen: false).addHabit(
                      Habit(
                        name: _name,
                        description: _description,
                        frequency: _frequency,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }
}
