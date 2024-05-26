import 'package:flutter/material.dart';
import 'habit_status.dart';
import 'user_mood.dart';

class Habit {
  String name;
  String description;
  List<String> frequency; // Days of the week this habit is to be performed
  bool archived;
  Map<DateTime, HabitStatus> status = {};
  Map<DateTime, UserMood> moods = {};

  Habit({
    required this.name,
    required this.description,
    required this.frequency, 
    this.archived = false,
    Map<DateTime, HabitStatus>? status,
    }) : status = status ?? {};

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'frequency': frequency,
      'archived': archived,
      'status': status.map((key, value) => MapEntry(key.toIso8601String(), value.toString())),
    };
  }

  static Habit fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      description: json['description'],
      frequency: List<String>.from(json['frequency']),
      archived: json['archived'],
      status: (json['status'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(DateTime.parse(key), HabitStatus.values.firstWhere((e) => e.toString() == value)),
      ),
    );
  }
}
