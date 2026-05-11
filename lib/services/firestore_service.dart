import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart'; // Ensure this matches your folder structure

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Dynamically gets the current user's secure ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Creates an isolated database path just for this user
  CollectionReference get _tasksRef {
    if (_userId == null) throw Exception("User must be logged in");
    return _db.collection('users').doc(_userId).collection('tasks');
  }

  // CREATE
  Future<void> addTask(TaskModel task) async {
    await _tasksRef.add(task.toMap());
  }

  // READ (Real-time stream filtered by status)
  Stream<List<TaskModel>> getTasksByStatus(String status) {
    return _tasksRef
        .where('status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // UPDATE (Moving a task to a new Kanban column)
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    await _tasksRef.doc(taskId).update({'status': newStatus});
  }

  // UPDATE (Editing an entire task)
  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) return;
    await _tasksRef.doc(task.id).update(task.toMap());
  }

  // DELETE
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }
}