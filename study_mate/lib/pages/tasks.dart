import 'package:flutter/material.dart';
import 'package:study_mate/notifiers/objects.dart';
import 'package:study_mate/pages/widgets.dart';

import '../notifiers/data.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({
    super.key,
    required this.lesson,
    });

    final Lesson lesson;

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
  uLesson = widget.lesson;
    return ValueListenableBuilder(
      valueListenable: lessonsNotifier,
      builder: (context, lesson, child) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: widget.lesson.tasks.isNotEmpty ? 
                      ListView.separated(
                          itemCount: widget.lesson.tasks.length,
                          itemBuilder: (context, index) => 
                            PersonalizedListTile(index : index, list : widget.lesson.tasks, lesson: widget.lesson),
                          separatorBuilder: (context, index) => const Divider(thickness: 5,color: Colors.transparent, height: 2,),
                        )
                      :
                      const Center(
                        child: Text("Aucune tâche pour cette matière."),
                      )
                    ),
                    MyTextButton(controller: controller, ver: 1,),
                  ],
                ),
        );
      }
    );
  }
}