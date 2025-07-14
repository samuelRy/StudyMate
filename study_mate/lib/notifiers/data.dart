import "dart:async";
import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "objects.dart";

bool loading = false;

List<Lesson> lessons = [];
List<Session> sessions = [];
late Lesson uLesson;

int learningTime = 0;
int sessionEnded = 0;
int tasksAccomplished = 0;

List<int> dates = [];
List<List<int>> weeks = [];

Timer? timer;
Map<bool, int> pomodoroRunning = {false: 0};

Brightness brightnessTheme = Brightness.dark;

ValueNotifier<Map<bool, int>> pomodoroRunningNotifier = ValueNotifier(pomodoroRunning);
ValueNotifier<Brightness> brightnessNotifier = ValueNotifier(brightnessTheme);
ValueNotifier<List<Lesson>> lessonsNotifier = ValueNotifier(lessons);
ValueNotifier<List<Session>> sessionsNotifier = ValueNotifier(sessions);

void _onLessonsChanged() => saveData();
void _onSessionsChanged() => saveData();
void _onBrightnessChanged() {
  brightnessTheme = brightnessNotifier.value;
  saveData();
}

Future<void> saveData() async {
  if (loading) return;
  final prefs = await SharedPreferences.getInstance();

  prefs.setBool("darkMode", brightnessNotifier.value == Brightness.dark);

  final lessonsJson = lessonsNotifier.value.map((lesson) => jsonEncode(lesson.toJson())).toList();
  final sessionsStr = sessionsNotifier.value.map((session) =>
      "${session.id},${session.date.toIso8601String()},${session.hour.hour}:${session.hour.minute}").join(";");


  prefs.setStringList("lessons", lessonsJson);
  prefs.setString("sessions", sessionsStr);
  prefs.setInt("learningTime", learningTime);
  prefs.setInt("sessionEnded", sessionEnded);
  prefs.setInt("tasksAccomplished", tasksAccomplished);
  prefs.setStringList("dates", dates.map((date) => date.toString()).toList());
  prefs.setStringList("weeks", weeks.map((week) => week.join(",")).toList());
}


Future<void> loadData() async {
  loading = true;
  final prefs = await SharedPreferences.getInstance();

  brightnessNotifier.value = prefs.getBool("darkMode") == true ? Brightness.dark : Brightness.light;

  // Load lessons
  final lessonStrings = prefs.getStringList("lessons") ?? [];
  lessons = lessonStrings.map((lesson) => Lesson.fromJson(jsonDecode(lesson))).toList();
  lessonsNotifier.value = lessons;
  // Load sessions
  final sessionString = prefs.getString("sessions") ?? "";
  sessions = sessionString.split(";").where((s) => s.isNotEmpty).map((session) {
    final parts = session.split(",");
    return Session(
      id: int.parse(parts[0]),
      date: DateTime.parse(parts[1]),
      hour: TimeOfDay(
        hour: int.parse(parts[2].split(":")[0]),
        minute: int.parse(parts[2].split(":")[1]),
      ),
    );
  }).toList();
  sessionsNotifier.value = sessions;

  // Load other data
  learningTime = prefs.getInt("learningTime") ?? 0;
  sessionEnded = prefs.getInt("sessionEnded") ?? 0;
  tasksAccomplished = prefs.getInt("tasksAccomplished") ?? 0;

  dates = (prefs.getStringList("dates") ?? []).map((dateStr) => int.parse(dateStr)).toList();

  final weekStrings = prefs.getStringList("weeks") ?? [];
  weeks = weekStrings.map((week) => week.split(",").map((day) => int.parse(day)).toList()).toList();

  loading = false;
}


void listenerFunction() {
   lessonsNotifier.removeListener(_onLessonsChanged); // prevent duplicate
  sessionsNotifier.removeListener(_onSessionsChanged);
  brightnessNotifier.removeListener(_onBrightnessChanged);

  lessonsNotifier.addListener(_onLessonsChanged);
  
  sessionsNotifier.addListener(_onSessionsChanged);

  brightnessNotifier.addListener(_onBrightnessChanged);
}