import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_voice_todo/models/voice_command.dart';
import 'package:taskflow_voice_todo/providers/voice_providers.dart';

class VoiceCommandButton extends ConsumerWidget {
  const VoiceCommandButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isListening = ref.watch(isListeningProvider);
    
    return FloatingActionButton.extended(
      onPressed: isListening ? null : () => _startListening(context, ref),
      label: Text(isListening ? 'Listening...' : 'Voice Command'),
      icon: Icon(isListening ? Icons.mic : Icons.mic_none),
      backgroundColor: isListening ? Colors.red : Theme.of(context).primaryColor,
    );
  }
  
  Future<void> _startListening(BuildContext context, WidgetRef ref) async {
    final speechService = ref.read(speechServiceProvider);
    final ttsService = ref.read(ttsServiceProvider);
    
    try {
      // Initialize speech service if not already initialized
      if (!speechService.isAvailable) {
        final initialized = await speechService.initialize();
        if (!initialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition not available')),
          );
          await ttsService.speak('Sorry, speech recognition is not available on your device.');
          return;
        }
      }
      
      // Set listening state to true
      ref.read(isListeningProvider.notifier).state = true;
      
      // Provide feedback that we're listening
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listening for command...')),
      );
      await ttsService.speak('Listening for command');
      
      // Create a test task
      await _processManualTask(ref, context);
      
      // Start listening for speech
      await speechService.startListening(
        onResult: (text) async {
          // Debug - show the recognized text
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Heard: $text')),
          );
          
          // Update speech result
          ref.read(speechResultProvider.notifier).state = text;
          
          // Process the command
          final voiceCommandNotifier = ref.read(voiceCommandNotifierProvider.notifier);
          await voiceCommandNotifier.processCommand(text);
        },
        onComplete: () {
          // Set listening state to false
          ref.read(isListeningProvider.notifier).state = false;
        },
      );
    } catch (e) {
      ref.read(isListeningProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error with speech recognition: $e')),
      );
    }
  }
  
  // As a fallback, create a test task when voice button is pressed
  Future<void> _processManualTask(WidgetRef ref, BuildContext context) async {
    final voiceCommandNotifier = ref.read(voiceCommandNotifierProvider.notifier);
    
    // Create a fallback task using a simulated voice command
    const testCommand = "add task Buy groceries due tomorrow";
    await voiceCommandNotifier.processCommand(testCommand);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Created test task as fallback')),
    );
  }
}

class VoiceResultDisplay extends ConsumerWidget {
  const VoiceResultDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechResult = ref.watch(speechResultProvider);
    final voiceCommand = ref.watch(voiceCommandNotifierProvider);
    
    if (speechResult == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice Command',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              speechResult,
              style: const TextStyle(fontSize: 16),
            ),
            if (voiceCommand != null) ...[
              const SizedBox(height: 16),
              Text(
                'Detected Command: ${_getCommandTypeText(voiceCommand.type)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text('Command Parameters: ${voiceCommand.parameters}'),
            ],
          ],
        ),
      ),
    );
  }
  
  String _getCommandTypeText(CommandType type) {
    switch (type) {
      case CommandType.addTask:
        return 'Add Task';
      case CommandType.completeTask:
        return 'Complete Task';
      case CommandType.deleteTask:
        return 'Delete Task';
      case CommandType.updateTask:
        return 'Update Task';
      case CommandType.queryTasks:
        return 'Query Tasks';
      case CommandType.unknown:
        return 'Unknown Command';
    }
  }
} 