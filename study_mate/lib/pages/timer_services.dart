import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_mate/notifiers/data.dart';

class TimerService extends ChangeNotifier {

  TimerService({required this.index});

  final int index;

  Duration time = const Duration(minutes: 25);
  bool isRunning = false;
  Timer? _timer;

  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    pomodoroRunningNotifier.value = {true: lessonsNotifier.value[index].id};
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //print("Timer tick: ${time.inSeconds}");
      if (time.inSeconds > 0 && isRunning) {
        time -= const Duration(seconds: 1);
        lessonsNotifier.value[index].time++;
        notifyListeners();
      } else {
        stopTimer();
        sessionEnded++;
        time = const Duration(minutes: 25);
        notifyListeners();
      }
    });
  }

  void pauseTimer() {
    if (!isRunning) return;
    isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void stopTimer() {
    pomodoroRunningNotifier.value = {false: lessonsNotifier.value[index].id};
    isRunning = false;
    _timer?.cancel();
    _timer = null;
    time = const Duration(minutes: 25);
    notifyListeners();
  }
}
