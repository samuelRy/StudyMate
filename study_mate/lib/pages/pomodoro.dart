import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:study_mate/pages/timer_services.dart';

class PomodoroWidget extends StatefulWidget {
  final TimerService timerService;

  const PomodoroWidget({super.key, required this.timerService});

  @override
  State<PomodoroWidget> createState() => _PomodoroWidgetState();
}

class _PomodoroWidgetState extends State<PomodoroWidget> {
  late final TimerService timerService;

  @override
  void initState() {
    super.initState();
    timerService = widget.timerService;

    timerService.addListener(_update);
  }

  void _update() {
    setState(() {});
  }

  @override
  void dispose() {
    timerService.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = timerService.isRunning;
    final isInitial = timerService.time == const Duration(minutes: 25);
    final isPaused = !isRunning && !isInitial;
    final canStart = !isRunning && (isInitial || isPaused);
    final duration = timerService.time;
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
          Center(
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
                      child: TextButton(
                        onPressed: canStart ? () => timerService.startTimer() : null,
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Text("Démarrer"),
                      ),
                    ),
                    SizedBox(width: 15),
                    Transform.scale(
                      scale: 1.2,
                      child: TextButton(
                        onPressed: isRunning ? () => timerService.pauseTimer() : null,
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        child: Text("Pause"),
                      ),
                    ),
                    SizedBox(width: 15),
                    Transform.scale(
                      scale: 1.2,
                      child: TextButton(
                        onPressed:
                            isRunning || isPaused
                                ? () => timerService.stopTimer()
                                : null,
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        child: Text("Arrèter"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
