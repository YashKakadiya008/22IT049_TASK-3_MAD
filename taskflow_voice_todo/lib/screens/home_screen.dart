import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_voice_todo/providers/task_providers.dart';
import 'package:taskflow_voice_todo/providers/voice_providers.dart';
import 'package:taskflow_voice_todo/widgets/task_list.dart';
import 'package:taskflow_voice_todo/widgets/voice_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => _initializeApp());
  }
  
  Future<void> _initializeApp() async {
    try {
      // Initialize local repository
      final localRepo = ref.read(localTaskRepositoryProvider);
      await localRepo.initialize();
      
      // Load tasks into state
      final taskNotifier = ref.read(taskNotifierProvider.notifier);
      await taskNotifier.loadTasks();
      
      // Set initialized flag
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final speechResult = ref.watch(speechResultProvider);
    
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading your tasks...', 
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow Voice Todo'),
        actions: [
          Icon(
            isOnline ? Icons.wifi : Icons.wifi_off,
            color: isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Voice command result display
          if (speechResult != null) const VoiceResultDisplay(),
          
          // Task list
          const Expanded(
            child: TaskList(),
          ),
        ],
      ),
      floatingActionButton: const VoiceCommandButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
} 