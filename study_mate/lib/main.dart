import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import "package:study_mate/notifiers/data.dart";
import "pages/home.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("test", "hello");
  await loadData();
  listenerFunction();
  checkAndRunWeeklyTask();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool modeOff = brightnessNotifier.value == Brightness.light;
    return ValueListenableBuilder(
      valueListenable: brightnessNotifier,
      builder: (context, brightness, child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: brightness,
                ),
            ),
            home: Scaffold(
          appBar: AppBar(
            title: Text('Study Mate'),
            actions: [
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: modeOff,
                  thumbIcon: modeOff
                    ? WidgetStateProperty.all(Icon(Icons.light_mode_outlined))
                    : WidgetStateProperty.all(Icon(Icons.dark_mode_outlined)),
                  onChanged: (value) {
                    modeOff = value;
                    brightnessNotifier.value = modeOff ? Brightness.light : Brightness.dark;
                  },
                ),
              )
            ],
            ),
          body: HomePage(),
          ),
        );
      }
    );
  }

}

Future<void> checkAndRunWeeklyTask() async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();

  // Get the current week number
  final currentWeek = _getWeekNumber(now);
  final lastWeek = prefs.getInt('last_week_run') ?? -1;

  if (currentWeek != lastWeek) {
    // Run your function here
    //await _runWeeklyTask();

    // Store the current week number
    await prefs.setInt('last_week_run', currentWeek);
  }
}

int _getWeekNumber(DateTime date) {
  final beginningOfYear = DateTime(date.year, 1, 1);
  final daysPassed = date.difference(beginningOfYear).inDays;
  return ((daysPassed + beginningOfYear.weekday) / 7).ceil();
}