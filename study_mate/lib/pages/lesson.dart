import 'package:flutter/material.dart';
import "package:lottie/lottie.dart";
import "package:study_mate/notifiers/data.dart";
import "package:study_mate/pages/plan.dart";
import "package:study_mate/pages/tasks.dart";
import "../notifiers/objects.dart";

class LessonPage extends StatefulWidget {
  const LessonPage({
    super.key,
    required this.lesson,
    });

    final Lesson lesson;
  
  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int navigationPage = 0;
  late Widget page;
  @override
  Widget build(BuildContext context) {
  uLesson = widget.lesson;

  if (navigationPage == 0) {
    page = TasksWidget(lesson: widget.lesson,);
  } else if (navigationPage == 1){
    page = PlanWidget(lesson: widget.lesson);
  } else if (navigationPage == 2){
  }
    return ValueListenableBuilder(
      valueListenable: lessonsNotifier,
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.lesson.name),
          ),
          body: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Stack(
              children: [
              Positioned.fill(
                    child: Opacity(
                      opacity: 0.5,
                      child: Lottie.asset(
                        "assets/animations/homeStudyMate.json",
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),
                page,
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationPage,
            onDestinationSelected: (value) {
              setState(() {
                navigationPage = value;
              });
            },
            destinations: [
              NavigationDestination(icon: Icon(Icons.task_outlined), label: "Taches"),
              NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: "Planification"),
              NavigationDestination(icon: Icon(Icons.timer_outlined), label: "Porodomo"),
            ],
          ),
        );
      }
    );
  }
}

