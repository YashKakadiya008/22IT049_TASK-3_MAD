import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_voice_todo/models/task.dart';
import 'package:taskflow_voice_todo/models/voice_command.dart';
import 'package:taskflow_voice_todo/repositories/local_task_repository.dart';
import 'package:taskflow_voice_todo/services/command_parser_service.dart';
import 'package:taskflow_voice_todo/services/speech_service.dart';
import 'package:taskflow_voice_todo/services/tts_service.dart';
import 'package:taskflow_voice_todo/providers/task_providers.dart';

// Provider for speech service
final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});

// Provider for TTS service
final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

// Provider for command parser service
final commandParserServiceProvider = Provider<CommandParserService>((ref) {
  return CommandParserService();
});

// Provider for speech recognition status
final isListeningProvider = StateProvider<bool>((ref) => false);

// Provider for speech recognition result
final speechResultProvider = StateProvider<String?>((ref) => null);

// Provider for unprocessed voice commands
final unprocessedCommandsProvider = Provider<List<VoiceCommand>>((ref) {
  final localRepository = ref.watch(localTaskRepositoryProvider);
  return localRepository.getUnprocessedCommands();
});

// Notifier for voice command processing
class VoiceCommandNotifier extends StateNotifier<VoiceCommand?> {
  final CommandParserService commandParser;
  final LocalTaskRepository localRepository;
  final TaskNotifier taskNotifier;
  final TtsService ttsService;
  
  VoiceCommandNotifier({
    required this.commandParser,
    required this.localRepository,
    required this.taskNotifier,
    required this.ttsService,
  }) : super(null);
  
  // Process a voice command
  Future<void> processCommand(String voiceText) async {
    // Parse the raw text into a command
    final command = commandParser.parseCommand(voiceText);
    
    // Save the command for offline processing
    await localRepository.saveVoiceCommand(command);
    
    // Set the current command
    state = command;
    
    // Process the command
    await _executeCommand(command);
    
    // Provide audio feedback
    await _provideAudioFeedback(command);
    
    // Mark command as processed
    await localRepository.markCommandAsProcessed(command.id);
  }
  
  // Execute a command
  Future<void> _executeCommand(VoiceCommand command) async {
    switch (command.type) {
      case CommandType.addTask:
        await _handleAddTask(command);
        break;
      case CommandType.completeTask:
        await _handleCompleteTask(command);
        break;
      case CommandType.deleteTask:
        await _handleDeleteTask(command);
        break;
      case CommandType.updateTask:
        await _handleUpdateTask(command);
        break;
      case CommandType.queryTasks:
        // Query handling would be implemented in the UI layer
        break;
      case CommandType.unknown:
        // Handle unknown command
        break;
    }
  }
  
  // Handle add task command
  Future<void> _handleAddTask(VoiceCommand command) async {
    final title = command.parameters['title'] as String? ?? 'New Task';
    final dueDate = command.parameters['dueDate'] as DateTime?;
    final tags = command.parameters['tags'] as List<String>? ?? [];
    
    final task = Task(
      title: title,
      dueDate: dueDate,
      tags: tags,
    );
    
    await taskNotifier.addTask(task);
  }
  
  // Handle complete task command
  Future<void> _handleCompleteTask(VoiceCommand command) async {
    final taskIdentifier = command.parameters['taskIdentifier'] as String? ?? '';
    if (taskIdentifier.isEmpty) return;
    
    // Find task by title (simple approach)
    final tasks = await localRepository.getTasksByTitle(taskIdentifier);
    if (tasks.isNotEmpty) {
      final task = tasks.first;
      await taskNotifier.toggleTaskCompletion(task.id);
    }
  }
  
  // Handle delete task command
  Future<void> _handleDeleteTask(VoiceCommand command) async {
    final taskIdentifier = command.parameters['taskIdentifier'] as String? ?? '';
    if (taskIdentifier.isEmpty) return;
    
    // Find task by title (simple approach)
    final tasks = await localRepository.getTasksByTitle(taskIdentifier);
    if (tasks.isNotEmpty) {
      final task = tasks.first;
      await taskNotifier.deleteTask(task.id);
    }
  }
  
  // Handle update task command
  Future<void> _handleUpdateTask(VoiceCommand command) async {
    final taskIdentifier = command.parameters['taskIdentifier'] as String? ?? '';
    if (taskIdentifier.isEmpty) return;
    
    // Find task by title (simple approach)
    final tasks = await localRepository.getTasksByTitle(taskIdentifier);
    if (tasks.isEmpty) return;
    
    final task = tasks.first;
    
    // Check what to update
    if (command.parameters.containsKey('newValue')) {
      final newValue = command.parameters['newValue'] as String;
      final updatedTask = task.copyWith(title: newValue);
      await taskNotifier.updateTask(updatedTask);
    } else if (command.parameters.containsKey('newDueDate')) {
      final newDueDate = command.parameters['newDueDate'] as DateTime;
      final updatedTask = task.copyWith(dueDate: newDueDate);
      await taskNotifier.updateTask(updatedTask);
    }
  }
  
  // Provide audio feedback for commands
  Future<void> _provideAudioFeedback(VoiceCommand command) async {
    String feedback;
    
    switch (command.type) {
      case CommandType.addTask:
        final title = command.parameters['title'] as String? ?? 'New Task';
        feedback = 'Task added: $title';
        break;
      case CommandType.completeTask:
        feedback = 'Task marked as complete';
        break;
      case CommandType.deleteTask:
        feedback = 'Task deleted';
        break;
      case CommandType.updateTask:
        feedback = 'Task updated';
        break;
      case CommandType.queryTasks:
        feedback = 'Showing tasks';
        break;
      case CommandType.unknown:
        feedback = 'Sorry, I didn\'t understand that command';
        break;
    }
    
    await ttsService.speak(feedback);
  }
  
  // Process any unprocessed commands (for offline sync)
  Future<void> processUnprocessedCommands() async {
    final commands = localRepository.getUnprocessedCommands();
    
    for (final command in commands) {
      state = command;
      await _executeCommand(command);
      await localRepository.markCommandAsProcessed(command.id);
    }
  }
}

// Provider for voice command notifier
final voiceCommandNotifierProvider = StateNotifierProvider<VoiceCommandNotifier, VoiceCommand?>((ref) {
  final commandParser = ref.watch(commandParserServiceProvider);
  final localRepository = ref.watch(localTaskRepositoryProvider);
  final taskNotifier = ref.watch(taskNotifierProvider.notifier);
  final ttsService = ref.watch(ttsServiceProvider);
  
  return VoiceCommandNotifier(
    commandParser: commandParser,
    localRepository: localRepository,
    taskNotifier: taskNotifier,
    ttsService: ttsService,
  );
}); 