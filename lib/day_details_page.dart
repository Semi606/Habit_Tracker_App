import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'habit.dart';
import 'habit_status.dart';
import 'user_mood.dart';

class DayDetailsPage extends StatelessWidget {
  final DateTime date;

  DayDetailsPage({required this.date});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Day Details'),
      ),
      body: FutureBuilder<int>(
        future: habitProvider.getStepsCount(date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            int steps = snapshot.data ?? 0;
            return Column(
              children: [
                Text(
                  '${date.day}-${date.month}-${date.year}',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'Steps: $steps',
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                child: ListView.builder(
                  itemCount: habitProvider.habits.length,
                  itemBuilder: (context, index) {
                    final habit = habitProvider.habits[index];
                    final status = habit.status[date] ?? HabitStatus.planned;
                    return ListTile(
                      title: Text(habit.name),
                      subtitle: Text('Status: ${_statusToString(status)}'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'How was your day?',
                  style: TextStyle(fontSize: 18),
                ),
              ),
                Text('How was your day?'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: UserMood.values.map((mood) {
                    return IconButton(
                      icon: Icon(
                        _moodToIcon(mood),
                        color: habitProvider.getUserMood(date) == mood ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        habitProvider.updateUserMood(date, mood);
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          }
        },
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

  IconData _moodToIcon(UserMood mood) {
    switch (mood) {
      case UserMood.happy:
        return Icons.sentiment_satisfied;
      case UserMood.neutral:
        return Icons.sentiment_neutral;
      case UserMood.sad:
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
