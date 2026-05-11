import 'package:flutter/material.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/screens/profile_screen.dart';
import 'package:task_manager/services/api_service.dart';
import 'package:task_manager/services/auth_service.dart';
import 'package:task_manager/services/firestore_service.dart';
import 'package:task_manager/screens/task_form_screen.dart';
import 'package:task_manager/widgets/task_item.dart'; // New Import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  Map<String, String>? _quoteData;
  bool _isLoadingQuote = true;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    try {
      final quote = await _apiService.fetchQuote();
      if (mounted) {
        setState(() {
          _quoteData = quote;
          _isLoadingQuote = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingQuote = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: const Text(
            'My Board', 
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)
          ),
         // Update this specific section in your AppBar actions
actions: [
  IconButton(
    icon: const Icon(Icons.person_outline),
    tooltip: 'Profile',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    },
  ),
  IconButton(
    icon: const Icon(Icons.logout_rounded),
    tooltip: 'Sign Out',
    onPressed: () async {
      await _authService.signOut();
      // This forces the app to restart at the initial route (Login)
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    },
  )
],
          bottom: TabBar(
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey[500],
            indicatorColor: theme.primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'TO DO'),
              Tab(text: 'IN PROGRESS'),
              Tab(text: 'DONE'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildQuoteBanner(theme),
            Expanded(
              child: TabBarView(
                children: [
                  _buildKanbanColumn('To Do'),
                  _buildKanbanColumn('In Progress'),
                  _buildKanbanColumn('Done'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const TaskFormScreen())
            );
          },
          elevation: 3,
          icon: const Icon(Icons.add),
          label: const Text("New Task", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildQuoteBanner(ThemeData theme) {
    if (_isLoadingQuote) {
      return const LinearProgressIndicator(minHeight: 2);
    }
    if (_quoteData == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Text(
            '"${_quoteData!['quote']}"',
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '— ${_quoteData!['author']}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String status) {
    return StreamBuilder<List<TaskModel>>(
      stream: _firestoreService.getTasksByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading tasks', style: TextStyle(color: Colors.grey[600])));
        }
        
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No tasks in $status', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            // Using the new modular TaskItem widget
            return TaskItem(
              task: task,
              status: status,
              onAction: (newAction) {
                if (newAction == 'Edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskFormScreen(existingTask: task),
                    ),
                  );
                } else if (newAction == 'Delete') {
                  _firestoreService.deleteTask(task.id!);
                } else {
                  _firestoreService.updateTaskStatus(task.id!, newAction);
                }
              },
            );
          },
        );
      },
    );
  }
}