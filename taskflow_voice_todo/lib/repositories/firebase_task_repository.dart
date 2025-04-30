import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskflow_voice_todo/models/task.dart';

class FirebaseTaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference for tasks
  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    // Get current user ID or use anonymous ID
    final userId = _auth.currentUser?.uid ?? 'anonymous';
    return _firestore.collection('users/$userId/tasks');
  }
  
  // Get all tasks from Firestore
  Stream<List<Task>> getTasks() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Ensure ID is part of the data
            return Task.fromMap(data);
          }).toList();
        });
  }
  
  // Add a task to Firestore
  Future<void> addTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toMap());
  }
  
  // Update a task in Firestore
  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
  }
  
  // Delete a task from Firestore
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }
  
  // Batch sync tasks (for offline to online sync)
  Future<void> batchSyncTasks(List<Task> tasks) async {
    final batch = _firestore.batch();
    
    for (final task in tasks) {
      final docRef = _tasksCollection.doc(task.id);
      batch.set(docRef, task.toMap(), SetOptions(merge: true));
    }
    
    await batch.commit();
  }
  
  // Get a task by its ID
  Future<Task?> getTaskById(String taskId) async {
    final docSnapshot = await _tasksCollection.doc(taskId).get();
    
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        data['id'] = docSnapshot.id;
        return Task.fromMap(data);
      }
    }
    
    return null;
  }
  
  // Get tasks that match a title query
  Future<List<Task>> getTasksByTitle(String query) async {
    // Firestore doesn't directly support LIKE queries, so we use startAt and endAt
    // This is a simple implementation for demo purposes
    final queryText = query.toLowerCase();
    
    final querySnapshot = await _tasksCollection
        .orderBy('title')
        .startAt([queryText])
        .endAt([queryText + '\uf8ff'])
        .get();
    
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Task.fromMap(data);
    }).toList();
  }
  
  // Listen to real-time changes for a specific task
  Stream<Task?> watchTask(String taskId) {
    return _tasksCollection.doc(taskId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          data['id'] = snapshot.id;
          return Task.fromMap(data);
        }
      }
      return null;
    });
  }
  
  // Initialize Firebase Auth (anonymous auth for simplicity)
  Future<void> initializeAuth() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }
} 