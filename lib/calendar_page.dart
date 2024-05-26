import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'habit_provider.dart';
import 'habit.dart';
import 'habit_status.dart';
import 'day_details_page.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  List<HabitStatus> _getEventsForDay(DateTime day) {
    final habitProvider = Provider.of<HabitProvider>(context);
    return habitProvider.getHabitStatuses(day);
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () async {
              await habitProvider.signInWithGoogle();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayDetailsPage(date: selectedDay),
                ),
              );
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final habitStatuses = _getEventsForDay(date);
                if (habitStatuses.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: habitStatuses.map((status) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: status == HabitStatus.completed
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: habitProvider.habits.length,
              itemBuilder: (context, index) {
                final habit = habitProvider.habits[index];
                final status = habit.status[_selectedDay] ?? HabitStatus.planned;
                return ListTile(
                  title: Text(habit.name),
                  subtitle: Text('Status: ${_statusToString(status)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.check,
                          color: status == HabitStatus.completed ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          habitProvider.updateHabitStatus(habit, _selectedDay, HabitStatus.completed);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: status == HabitStatus.missed ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          habitProvider.updateHabitStatus(habit, _selectedDay, HabitStatus.missed);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          habitProvider.removeHabit(habit);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Edit Habit'),
                          content: TextFormField(
                            initialValue: habit.name,
                            onChanged: (value) {
                              habit.name = value;
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String name = '';
              String description = '';
              return AlertDialog(
                title: Text('Add Habit'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (name.isNotEmpty) {
                        habitProvider.addHabit(Habit(
                          name: name,
                          description: description,
                          frequency: ['M', 'T', 'W', 'Th', 'F'], // Just as example
                        ));
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

    String _statusToString(HabitStatus status) {
    switch (status) {
      case HabitStatus.completed:
        return 'completed';
      case HabitStatus.missed:
        return 'missed';
      case HabitStatus.planned:
        return 'planned';
      default:
        return '';
    }
  }
}
