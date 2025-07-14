import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:study_mate/notifiers/data.dart';
import 'package:study_mate/notifiers/objects.dart';
import 'package:study_mate/pages/lesson.dart';

import 'timer_services.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({super.key, required this.controller, required this.ver});
  final TextEditingController controller;
  final int ver;

  @override
  Widget build(BuildContext context) {
    Future<DateTime?> selectDate() async {
      DateTime? dt = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 2),
      );
      return dt;
    }

    Future<TimeOfDay?> seleHour() async {
      TimeOfDay? dt = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      return dt;
    }
    return Positioned(
      bottom: 25,
      right: 25,
      child: FloatingActionButton(
        onPressed:
            (ver != 2)
                ? () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title:
                            ver == 0
                                ? const Text("Ajouter une matière")
                                : const Text("Ajouter une tache"),
                        content: TextField(
                          maxLength: 100,
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            label: Text("Nom"),
                            counterText: "",
                            hintText:
                                ver == 0
                                    ? "Nom de la matière"
                                    : "Nom de la tache",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              textStyle: Theme.of(context).textTheme.labelLarge,
                            ),
                            child: Text("Annuler"),
                          ),
                          if (ver == 0)
                            TextButton(
                              onPressed: () {
                                lessonsNotifier.value =
                                    lessonsNotifier.value +
                                    [
                                      Lesson(
                                        id: lessonsNotifier.value.length,
                                        name: controller.text,
                                      ),
                                    ];
                                controller.clear();
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: Text("Ajouter"),
                            ),
                          if (ver == 1)
                            TextButton(
                              onPressed: () {
                                uLesson.addTask(controller.text);
                                lessonsNotifier.value =
                                    lessonsNotifier.value
                                        .map(
                                          (lesson) =>
                                              ((lesson.id != uLesson.id) &&
                                                      (lesson.name !=
                                                          uLesson.name))
                                                  ? uLesson
                                                  : lesson,
                                        )
                                        .toList();
                                controller.clear();
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: Text("Ajouter"),
                            ),
                        ],
                      );
                    },
                  );
                }
                : () async {
                  DateTime? date = await selectDate();
                  TimeOfDay? hour = await seleHour();
                  if (date != null && hour != null) {
                    sessionsNotifier.value = List.from(sessionsNotifier.value)
                      ..add(
                        Session(
                          id: sessionsNotifier.value.length,
                          date: date,
                          hour: hour,
                        ),
                      );
                    uLesson.addSession(sessionsNotifier.value.length - 1);
                    lessonsNotifier.value =
                        lessonsNotifier.value
                            .map(
                              (lesson) =>
                                  ((lesson.id != uLesson.id) &&
                                          (lesson.name != uLesson.name))
                                      ? uLesson
                                      : lesson,
                            )
                            .toList();
                  }
                },
        child: Icon(Icons.add),
      ),
    );
  }
}

class PersonalizedListTile extends StatefulWidget {
  const PersonalizedListTile({
    super.key,
    required this.index,
    required this.list,
    this.lesson,
  });

  final int index;
  final dynamic list;
  final Lesson? lesson;

  @override
  State<PersonalizedListTile> createState() => _PersonalizedListTileState();
}

class _PersonalizedListTileState extends State<PersonalizedListTile> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    //(widget.list is! List<dynamic>) ? print('${widget.list[widget.index].keys.last}') : null;
    return MouseRegion(
      onEnter:
          (event) => setState(() {
            isHovering = true;
          }),
      onExit:
          (event) => setState(() {
            isHovering = false;
          }),
      child:
          (widget.list is List<dynamic>)
              ? AnimatedScale(
                scale: isHovering ? 1.01 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Card(
                  color:
                      !isHovering
                          ? Theme.of(context).colorScheme.surfaceContainerLow
                          : Theme.of(context).colorScheme.surfaceContainerHigh,
                  shadowColor: Colors.black,
                  elevation: isHovering ? 1.8 : 1.9,
                  child: RawGestureDetector(
                    gestures: {
                      LongPressGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                            LongPressGestureRecognizer
                          >(
                            () => LongPressGestureRecognizer(
                              duration: const Duration(milliseconds: 700),
                            ),
                            (instance) {
                              instance.onLongPressStart = (details) {
                                if (widget.list[0] is Lesson) {
                                  lessonsNotifier.value = List.from(
                                    lessonsNotifier.value,
                                  )..removeAt(widget.index);
                                } else {
                                  sessionsNotifier.value = List.from(
                                    sessionsNotifier.value,
                                  )..removeAt(widget.index);
                                }
                              };
                            },
                          ),
                    },
                    child: ListTile(
                      title: Text(
                        widget.list[0] is Session
                            ? "${widget.list[widget.index].id}"
                            : "${widget.list[widget.index].name}",
                      ),

                      leading: Icon(
                        widget.list[0] is Lesson
                            ? Icons.book_outlined
                            : widget.list[0] is Session
                            ? Icons.calendar_today_outlined
                            : Icons.task_outlined,
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        (widget.list[0] is! Session)
                            ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => LessonPage(
                                      lesson: widget.list[widget.index],
                                    ),
                              ),
                            )
                            : showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Session id n°${widget.list[widget.index].id}",
                                  ),
                                  content: Text(
                                    "${formatDate(widget.list[widget.index].date)} - ${formatHour(widget.list[widget.index].hour)}",
                                  ),
                                );
                              },
                            );
                      },
                    ),
                  ),
                ),
              )
              : AnimatedScale(
                scale: isHovering ? 1.01 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Card(
                  color:
                      !isHovering
                          ? Theme.of(context).colorScheme.surfaceContainerLow
                          : Theme.of(context).colorScheme.surfaceContainerHigh,
                  shadowColor: Colors.black,
                  elevation: isHovering ? 1.8 : 1.9,
                  child: RawGestureDetector(
                    gestures: {
                      LongPressGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                            LongPressGestureRecognizer
                          >(
                            () => LongPressGestureRecognizer(
                              duration: const Duration(milliseconds: 700),
                            ),
                            (instance) {
                              instance.onLongPressStart = (details) {
                                switch (widget.lesson) {
                                  case _:
                                    Lesson tLessons =
                                        lessonsNotifier.value
                                            .where(
                                              (lesson) =>
                                                  lesson.id ==
                                                  widget.lesson!.id,
                                            )
                                            .first;
                                    tLessons.tasks =
                                        widget.list..remove(widget.index);
                                    lessonsNotifier.value =
                                        List.from(lessonsNotifier.value)
                                          ..removeWhere(
                                            (lesson) =>
                                                lesson.id == widget.lesson!.id,
                                          )
                                          ..add(tLessons);
                                }
                              };
                            },
                          ),
                    },
                    child: CheckboxListTile(
                      title: Text(widget.list[widget.index].keys.first),
                      mouseCursor: SystemMouseCursors.click,
                      value: widget.list[widget.index].values.first,
                      onChanged: (value) {
                        setState(() {
                          widget.list[widget.index][widget
                                  .list[widget.index]
                                  .keys
                                  .first] =
                              value;
                          tasksAccomplished +=
                              widget.list[widget.index].values.last == true
                                  ? 1
                                  : -1;
                        });
                      },
                    ),
                  ),
                ),
              ),
    );
  }
}

class PomodoroRunning extends StatefulWidget {
  final TimerService timerService;
  final VoidCallback? onSomeEvent;
  const PomodoroRunning({super.key, required this.timerService, this.onSomeEvent});

  @override
  State<PomodoroRunning> createState() => _PomodoroRunningState();
}

class _PomodoroRunningState extends State<PomodoroRunning> {
  late final TimerService timerService;

  @override
  void initState() {
    super.initState();
    widget.onSomeEvent?.call();
    timerService = widget.timerService;

    timerService.addListener(_update);
  }

  @override
  void dispose() {
    timerService.removeListener(_update);
    super.dispose();
  }
  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = timerService.isRunning;
    final isInitial = timerService.time == const Duration(minutes: 25);
    final isPaused = !isRunning && !isInitial;
    final canStart = !isRunning && (isInitial || isPaused);
    final duration = timerService.time;
    return Container(
      padding: const EdgeInsets.all(20),
      
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 2.5,
              child: Text(
                '${duration.inMinutes.toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 15,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: IconButton(
                    onPressed: canStart ? () => timerService.startTimer() : null,
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    icon: Icon(Icons.play_arrow_outlined),
                  ),
                ),
                SizedBox(width: 15),
                Transform.scale(
                  scale: 1.2,
                  child: IconButton(
                    onPressed: isRunning ? () => timerService.pauseTimer() : null,
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    icon: Icon(Icons.pause_outlined),
                  ),
                ),
                SizedBox(width: 15),
                Transform.scale(
                  scale: 1.2,
                  child: IconButton(
                    onPressed:
                        isRunning || isPaused
                            ? () => timerService.stopTimer()
                            : null,
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    icon: Icon(Icons.stop_outlined),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


String formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";
}

String formatHour(TimeOfDay time) {
  return "${time.hour.toString().padLeft(2, '0')}:"
      "${time.minute.toString().padLeft(2, '0')}";
}
