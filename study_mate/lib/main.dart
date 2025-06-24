import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const StudyApp());
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomeScreen(),
    );
  }
}

class Subject {
  String name;
  List<Task> tasks;
  List<StudySession> sessions;
  Duration totalStudyTime;

  Subject({
    required this.name,
    this.tasks = const [],
    this.sessions = const [],
    this.totalStudyTime = Duration.zero,
  });
}

class Task {
  String description;
  bool isCompleted;

  Task({required this.description, this.isCompleted = false});
}

class StudySession {
  DateTime dateTime;
  Duration duration;

  StudySession({required this.dateTime, required this.duration});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subject> subjects = [
    Subject(name: 'Programmation Web'),
    Subject(name: 'Mathématiques'),
  ];
  int _selectedIndex = 0;

  void _addSubject(String name) {
    setState(() {
      subjects.add(Subject(name: name));
    });
  }

  void _navigateToSubject(BuildContext context, Subject subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectDetailScreen(subject: subject),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      SubjectListScreen(subjects: subjects, onAddSubject: _addSubject, onTapSubject: _navigateToSubject),
      const StatsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book), label: 'Matières'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Statistiques'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddSubjectDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle matière'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nom de la matière'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addSubject(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class SubjectListScreen extends StatelessWidget {
  final List<Subject> subjects;
  final Function(String) onAddSubject;
  final Function(BuildContext, Subject) onTapSubject;

  const SubjectListScreen({
    super.key,
    required this.subjects,
    required this.onAddSubject,
    required this.onTapSubject,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          child: ListTile(
            title: Text(subject.name),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => onTapSubject(context, subject),
          ),
        );
      },
    );
  }
}

class SubjectDetailScreen extends StatefulWidget {
  final Subject subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  int _selectedIndex = 0;

  void _addTask(String description) {
    setState(() {
      widget.subject.tasks.add(Task(description: description));
    });
  }

  void _planStudySession(DateTime dateTime) {
    setState(() {
      widget.subject.sessions.add(StudySession(dateTime: dateTime, duration: Duration.zero));
    });
  }

  void _startPomodoro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PomodoroScreen(
          onSessionComplete: (duration) {
            setState(() {
              widget.subject.totalStudyTime += duration;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      TasksScreen(tasks: widget.subject.tasks, onAddTask: _addTask),
      StudyPlanScreen(sessions: widget.subject.sessions, onPlanSession: _planStudySession),
      PomodoroScreen(
        onSessionComplete: (duration) {
          setState(() {
            widget.subject.totalStudyTime += duration;
          });
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.task), label: 'Tâches'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Pomodoro'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context),
              child: const Icon(Icons.add),
            )
          : _selectedIndex == 1
              ? FloatingActionButton(
                  onPressed: () => _showDateTimePicker(context),
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle tâche'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Description de la tâche'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addTask(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showDateTimePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        _planStudySession(dateTime);
      }
    }
  }
}

class TasksScreen extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onAddTask;

  const TasksScreen({super.key, required this.tasks, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          child: CheckboxListTile(
            title: Text(task.description),
            value: task.isCompleted,
            onChanged: (value) {
              task.isCompleted = value ?? false;
              (context as Element).markNeedsBuild();
            },
          ),
        );
      },
    );
  }
}

class StudyPlanScreen extends StatelessWidget {
  final List<StudySession> sessions;
  final Function(DateTime) onPlanSession;

  const StudyPlanScreen({super.key, required this.sessions, required this.onPlanSession});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          child: ListTile(
            title: Text(DateFormat('dd/MM/yyyy HH:mm').format(session.dateTime)),
            subtitle: Text('Durée: ${session.duration.inMinutes} min'),
          ),
        );
      },
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  final Function(Duration) onSessionComplete;

  const PomodoroScreen({super.key, required this.onSessionComplete});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  bool _isRunning = false;
  int _seconds = 25 * 60;
  int _sessionCount = 0;

  @override
  Widget build(BuildContext context) {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$minutes:$secs',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: _isRunning ? null : () => _startTimer(context),
                child: const Text('Démarrer'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _isRunning ? () => _stopTimer() : null,
                child: const Text('Arrêter'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Sessions complétées: $_sessionCount'),
        ],
      ),
    );
  }

  void _startTimer(BuildContext context) {
    setState(() {
      _isRunning = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRunning && _seconds > 0) {
        setState(() {
          _seconds--;
        });
        _startTimer(context);
      } else if (_seconds == 0) {
        setState(() {
          _isRunning = false;
          _sessionCount++;
          widget.onSessionComplete(const Duration(minutes: 25));
          _seconds = 25 * 60;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session Pomodoro terminée !')),
        );
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
    });
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Statistiques à venir'),
    );
  }
}