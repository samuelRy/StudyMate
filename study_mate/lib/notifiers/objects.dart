import 'package:flutter/material.dart';
import 'package:study_mate/pages/timer_services.dart';

class Lesson {
  String name = "";
  int id = 0;
  int time = 0;
  List<int> sessions = [];
  Map<int, Map<String, bool>> tasks = {0:{"Learn Things" : false}};
  late TimerService timerService;

  Lesson({required this.name, required this.id}) : timerService = TimerService(index: id);

  void addSession(int sessionId)
  {
    sessions.add(sessionId);
  }

  void removeTask(int id)
  {
    tasks.containsKey(id) ? tasks.remove(id) : null;
  }

  void addTask(String taskName)
  {
    tasks[tasks.length] = {taskName : false};

  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "time": time,
      "sessions": sessions,
      "tasks": tasks.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    name: json['name'],
    id: json['id'],
  )
    ..time = json['time']
    ..sessions = List<int>.from(json['sessions'])
    ..tasks = (json["tasks"] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        int.parse(key),
        Map<String, bool>.from(value),
      ),
    );
  
}

class Session {
  int id;
  DateTime date;
  TimeOfDay hour;

  Session({required this.id, required this.date, required this.hour});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date.toIso8601String(),
      "hour": "${hour.hour}:${hour.minute}",
    };
  }
}
