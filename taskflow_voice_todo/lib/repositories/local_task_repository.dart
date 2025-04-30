import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskflow_voice_todo/models/task.dart';
import 'package:taskflow_voice_todo/models/voice_command.dart';

class LocalTaskRepository {
  static const String _taskBoxName = 'tasks';
  static const String _commandBoxName = 'commands';
  late Box<Task> _taskBox;
  late Box<VoiceCommand> _commandBox;
  
  // Initialize the repository
  Future<void> initialize() async {
    // Open boxes if not already open
    if (!Hive.isBoxOpen(_taskBoxName)) {
      _taskBox = await Hive.openBox<Task>(_taskBoxName);
    } else {
      _taskBox = Hive.box<Task>(_taskBoxName);
    }
    
    if (!Hive.isBoxOpen(_commandBoxName)) {
      _commandBox = await Hive.openBox<VoiceCommand>(_commandBoxName);
    } else {
      _commandBox = Hive.box<VoiceCommand>(_commandBoxName);
    }
  }
  
  // Get all tasks
  List<Task> getAllTasks() {
    return _taskBox.values.toList();
  }
  
  // Get a task by ID
  Task? getTaskById(String id) {
    try {
      return _taskBox.values.firstWhere(
        (task) => task.id == id, 
      );
    } catch (e) {
      return null;
    }
  }
  
  // Get tasks by title (for searching)
  List<Task> getTasksByTitle(String title) {
    return _taskBox.values.where(
      (task) => task.title.toLowerCase().contains(title.toLowerCase())
    ).toList();
  }
  
  // Add a new task
  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
  }
  
  // Update an existing task
  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }
  
  // Delete a task
  Future<void> deleteTask(String taskId) async {
    // Find the task with the given ID
    final taskKey = _taskBox.keys.firstWhere(
      (key) => _taskBox.get(key)?.id == taskId,
      orElse: () => null,
    );
    
    if (taskKey != null) {
      await _taskBox.delete(taskKey);
    }
  }
  
  // Save a voice command for offline queue
  Future<void> saveVoiceCommand(VoiceCommand command) async {
    await _commandBox.put(command.id, command);
  }
  
  // Get all unprocessed voice commands
  List<VoiceCommand> getUnprocessedCommands() {
    return _commandBox.values
        .where((command) => !command.isProcessed)
        .toList();
  }
  
  // Mark a voice command as processed
  Future<void> markCommandAsProcessed(String commandId) async {
    try {
      final command = _commandBox.values.firstWhere(
        (cmd) => cmd.id == commandId,
      );
      
      final updatedCommand = command.copyWith(isProcessed: true);
      
      // Find the key for the command with the given ID
      final commandKey = _commandBox.keys.firstWhere(
        (key) => _commandBox.get(key)?.id == commandId,
        orElse: () => null,
      );
      
      if (commandKey != null) {
        await _commandBox.put(commandKey, updatedCommand);
      }
    } catch (e) {
      // Command not found, no action needed
    }
  }
  
  // Delete processed commands (cleanup)
  Future<void> deleteProcessedCommands() async {
    for (final key in _commandBox.keys) {
      final command = _commandBox.get(key);
      if (command != null && command.isProcessed) {
        await _commandBox.delete(key);
      }
    }
  }
  
  // Clear all data (for testing or reset)
  Future<void> clearAll() async {
    await _taskBox.clear();
    await _commandBox.clear();
  }
  
  // Get tasks that are not synced with the cloud
  List<Task> getUnsyncedTasks() {
    return _taskBox.values.where((task) => !task.isSynced).toList();
  }
  
  // Mark a task as synced
  Future<void> markTaskAsSynced(String taskId) async {
    try {
      final task = _taskBox.values.firstWhere(
        (task) => task.id == taskId,
      );
      
      final updatedTask = task.copyWith(isSynced: true);
      
      // Find the key for the task with the given ID
      final taskKey = _taskBox.keys.firstWhere(
        (key) => _taskBox.get(key)?.id == taskId,
        orElse: () => null,
      );
      
      if (taskKey != null) {
        await _taskBox.put(taskKey, updatedTask);
      }
    } catch (e) {
      // Task not found, no action needed
    }
  }
} 