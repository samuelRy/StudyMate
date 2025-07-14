import 'package:flutter/material.dart';
import "package:lottie/lottie.dart";
import "package:study_mate/pages/widgets.dart";
import "../notifiers/data.dart";
import "statistics.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int navigationPage = 0;
  late Widget page;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
          valueListenable: pomodoroRunningNotifier,
          builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: lessonsNotifier,
          builder: (context, value, child) {
            if (navigationPage == 0) {
              page = Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child:
                        value.isNotEmpty
                            ? ListView.separated(
                              itemCount: value.length,
                              itemBuilder:
                                  (context, index) => PersonalizedListTile(
                                    index: index,
                                    list: value,
                                  ),
                              separatorBuilder:
                                  (context, index) => const Divider(
                                    thickness: 5,
                                    color: Colors.transparent,
                                    height: 2,
                                  ),
                            )
                            : const Center(
                              child: Text("Aucune matière. Ajoutez une matière."),
                            ),
                  ),
                  MyTextButton(controller: controller, ver: 0),
                  pomodoroRunningNotifier.value.keys.first
                      ? Positioned(
                        bottom: 10,
                        left: 10,
                        child: PomodoroRunning(
                          timerService:
                              lessonsNotifier
                                  .value[pomodoroRunningNotifier.value.values.first]
                                  .timerService,
                        ),
                      )
                      : Container(),
                ],
              );
            } else if (navigationPage == 1) {
              page = StatisticsPage();
            }
            return Scaffold(
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
                  NavigationDestination(icon: Icon(Icons.book_outlined), label: "Matières"),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    label: "Statistiques",
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  @override
  void dispose() {
    saveData();
    controller.dispose();
    super.dispose();
  }
}
