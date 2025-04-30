import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_voice_todo/providers/task_providers.dart';
import 'package:taskflow_voice_todo/providers/voice_providers.dart';
import 'package:taskflow_voice_todo/widgets/task_list.dart';
import 'package:taskflow_voice_todo/widgets/voice_button.dart';
import 'package:taskflow_voice_todo/widgets/help_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => _initializeApp());
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize local repository
      final localRepo = ref.read(localTaskRepositoryProvider);
      await localRepo.initialize();
      
      // Load tasks into state
      final taskNotifier = ref.read(taskNotifierProvider.notifier);
      await taskNotifier.loadTasks();
      
      // Set initialized flag and start animation
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _animationController.forward();
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const HelpDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final speechResult = ref.watch(speechResultProvider);
    final colorScheme = Theme.of(context).colorScheme;
    
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
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: colorScheme.surfaceVariant,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        scrolledUnderElevation: 4,
        backgroundColor: colorScheme.primaryContainer.withOpacity(0.8),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'TaskFlow Voice Todo',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          _buildPulsatingHelpButton(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: isOnline ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceVariant.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            children: [
              // Voice command result display
              if (speechResult != null) const VoiceResultDisplay(),
              
              // Task list header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.format_list_bulleted, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Your Tasks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Task list
              const Expanded(
                child: TaskList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const VoiceCommandButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildPulsatingHelpButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Transform.scale(
            scale: value,
            child: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                // Add haptic feedback
                HapticFeedback.lightImpact();
                _showHelpDialog();
              },
              tooltip: 'Voice Command Help',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
      onEnd: () {
        setState(() {
          // Restart the animation
        });
      },
    );
  }
} 