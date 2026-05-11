import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Absolute imports to your screens and services
import 'package:task_manager/services/auth_service.dart';
import 'package:task_manager/screens/login_screen.dart';
import 'package:task_manager/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),
      // The StreamBuilder acts as our traffic controller
      home: StreamBuilder(
        stream: AuthService().userStatus,
        builder: (context, snapshot) {
          // If Firebase confirms the user is logged in, show the Dashboard
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // If no user is logged in, show the Login Screen
          return const LoginScreen();
        },
      ),
    );
  }
}