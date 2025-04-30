import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_voice_todo/models/task.dart';
import 'package:taskflow_voice_todo/providers/task_providers.dart';

class TaskList extends ConsumerWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks yet. Use your voice to add tasks!',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskListItem(task: task);
      },
    );
  }
}

class TaskListItem extends ConsumerWidget {
  final Task task;
  
  const TaskListItem({Key? key, required this.task}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.read(taskNotifierProvider.notifier);
    
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        taskNotifier.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                taskNotifier.addTask(task);
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w500,
              color: task.isCompleted ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: _buildSubtitle(task),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) {
              taskNotifier.toggleTaskCompletion(task.id);
            },
          ),
          trailing: task.isSynced 
              ? const Icon(Icons.cloud_done, color: Colors.green, size: 16)
              : const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
        ),
      ),
    );
  }
  
  Widget? _buildSubtitle(Task task) {
    final List<Widget> elements = [];
    
    // Add due date if available
    if (task.dueDate != null) {
      elements.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 14),
            const SizedBox(width: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(task.dueDate!),
              style: TextStyle(
                color: _isDueDateOverdue(task.dueDate!) ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      );
    }
    
    // Add tags if available
    if (task.tags.isNotEmpty) {
      elements.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.label, size: 14),
            const SizedBox(width: 4),
            Text(task.tags.join(', ')),
          ],
        ),
      );
    }
    
    if (elements.isEmpty) {
      return null;
    }
    
    return Wrap(
      spacing: 8,
      children: elements,
    );
  }
  
  bool _isDueDateOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(now) && !task.isCompleted;
  }
} 