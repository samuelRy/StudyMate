import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:study_mate/notifiers/data.dart';
import 'package:study_mate/notifiers/objects.dart';
import 'package:study_mate/pages/widgets.dart';

class PlanWidget extends StatefulWidget {
  const PlanWidget({
    super.key,
    required this.lesson,
    });

    final Lesson lesson;

  @override
  State<PlanWidget> createState() => _PlanWidgetState();
}

class _PlanWidgetState extends State<PlanWidget> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: sessionsNotifier,
      builder: (context, value, child) {
        List<Session> lessonSessions = sessionsNotifier.value.where((session) => uLesson.sessions.contains(session.id)).toList();
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
                  children: [
                    Positioned.fill(
                    child: Opacity(
                      opacity: 0.5,
                      child: Lottie.asset(
                        "assets/animations/timerStudyMate.json",
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: lessonSessions.isNotEmpty ? 
                      ListView.separated(
                        itemCount: lessonSessions.length,
                        itemBuilder: (context, index) => 
                          PersonalizedListTile(index : index, list : lessonSessions,),
                        separatorBuilder: (context, index) => const Divider(thickness: 5,color: Colors.transparent, height: 2,),
                      ) :
                      const Center(
                        child: Text("Aucune session pour cette matière."),
                      )
                    ),
                    MyTextButton(controller: controller, ver: 2,),
                  ],
                ),
        );
      }
    );
  }
}