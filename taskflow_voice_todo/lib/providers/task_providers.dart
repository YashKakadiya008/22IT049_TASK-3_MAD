import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_voice_todo/models/task.dart';
import 'package:taskflow_voice_todo/repositories/local_task_repository.dart';
import 'package:taskflow_voice_todo/services/connectivity_service.dart';

// Provider for local task repository
final localTaskRepositoryProvider = Provider<LocalTaskRepository>((ref) {
  return LocalTaskRepository();
});

// Provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// Provider for online status
final onlineStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.onConnectionChange;
});

// Provider for current online status (non-stream version)
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.isOnline;
});

// Provider for all tasks from local storage
final localTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.watch(localTaskRepositoryProvider);
  return repository.getAllTasks();
});

// Provider for all tasks that need syncing
final unsyncedTasksProvider = Provider<List<Task>>((ref) {
  final repository = ref.watch(localTaskRepositoryProvider);
  return repository.getUnsyncedTasks();
});

// Notifier for task operations
class TaskNotifier extends StateNotifier<List<Task>> {
  final LocalTaskRepository localRepository;
  final ConnectivityService connectivityService;
  
  TaskNotifier({
    required this.localRepository,
    required this.connectivityService,
  }) : super([]);
  
  // Load tasks from local storage
  Future<void> loadTasks() async {
    state = localRepository.getAllTasks();
  }
  
  // Add a new task
  Future<void> addTask(Task task) async {
    // Add to local storage
    await localRepository.addTask(task);
    
    // Update state
    state = [...state, task];
  }
  
  // Update a task
  Future<void> updateTask(Task task) async {
    // Update locally
    await localRepository.updateTask(task);
    
    // Update state
    state = state.map((t) => t.id == task.id ? task : t).toList();
  }
  
  // Delete a task
  Future<void> deleteTask(String taskId) async {
    // Delete locally
    await localRepository.deleteTask(taskId);
    
    // Update state
    state = state.where((task) => task.id != taskId).toList();
  }
  
  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = state.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;
    
    final task = state[taskIndex];
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    
    await updateTask(updatedTask);
  }
  
  // Sync unsynced tasks (stub for offline-only)
  Future<void> syncUnsyncedTasks() async {
    // This is a stub since we're not using cloud sync
    return;
  }
}

// Provider for task notifier
final taskNotifierProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final localRepository = ref.watch(localTaskRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return TaskNotifier(
    localRepository: localRepository,
    connectivityService: connectivityService,
  );
}); 