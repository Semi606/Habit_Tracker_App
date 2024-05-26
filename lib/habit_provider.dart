import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'habit.dart';
import 'habit_status.dart';
import 'user_mood.dart';
import 'package:health/health.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  final HealthFactory _health = HealthFactory();
  GoogleSignInAccount? _currentUser;

  HabitProvider() {
    _loadHabitsFromLocal();
  }

  List<Habit> get habits => _habits.where((habit) => !habit.archived).toList();

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/fitness.activity.read',
        'https://www.googleapis.com/auth/fitness.activity.write',
      ],
    );
    _currentUser = await googleSignIn.signIn();
    notifyListeners();
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveHabitsToLocal();
    notifyListeners();
  }

  void removeHabit(Habit habit) {
    habit.archived = true;
    _saveHabitsToLocal();
    notifyListeners();
  }

  void updateHabitStatus(Habit habit, DateTime date, HabitStatus status) {
    habit.status[date] = status;
    _saveHabitsToLocal();
    notifyListeners();
  }

  void updateUserMood(DateTime date, UserMood mood) {
    _userMoods[date] = mood;
    _saveHabitsToLocal();
    notifyListeners();
  }

  UserMood? getUserMood(DateTime date) {
    return _userMoods[date];
  }

  Future<int> getStepsCount(DateTime date) async {
    if (_currentUser == null) return 0;

    final DateTime start = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final DateTime end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final bool authorized = await _health.requestAuthorization([HealthDataType.STEPS]);

    if (authorized) {
      final int? steps = await _health.getTotalStepsInInterval(start, end);
      return steps ?? 0;
    } else {
      return 0;
    }
  }

  Map<DateTime, UserMood> _userMoods = {};

  // Add this method to return habit statuses for a given day
  List<HabitStatus> getHabitStatuses(DateTime day) {
    List<HabitStatus> statuses = [];
    for (Habit habit in _habits) {
      if (habit.status.containsKey(day)) {
        statuses.add(habit.status[day]!);
      }
    }
    return statuses;
  }
Future<void> _saveHabitsToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habitList = _habits.map((habit) => jsonEncode(habit.toJson())).toList();
    await prefs.setStringList('habits', habitList);
  }

  Future<void> _loadHabitsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? habitList = prefs.getStringList('habits');
    if (habitList != null) {
      _habits = habitList.map((habit) => Habit.fromJson(jsonDecode(habit))).toList();
    }
    notifyListeners();
  }

  Future<void> _saveUserMoodsToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> moodMap = _userMoods.map((key, value) => MapEntry(key.toIso8601String(), value.toString()));
    await prefs.setString('userMoods', jsonEncode(moodMap));
  }

  Future<void> _loadUserMoodsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? moodMapString = prefs.getString('userMoods');
    if (moodMapString != null) {
      Map<String, String> moodMap = Map<String, String>.from(jsonDecode(moodMapString));
      _userMoods = moodMap.map((key, value) => MapEntry(DateTime.parse(key), UserMood.values.firstWhere((e) => e.toString() == value)));
    }
    notifyListeners();
  }
}

