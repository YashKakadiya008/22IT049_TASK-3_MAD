import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  List<String> tags;

  @HiveField(7)
  bool isSynced;

  Task({
    String? id,
    required this.title,
    this.description,
    DateTime? createdAt,
    this.dueDate,
    this.isCompleted = false,
    List<String>? tags,
    this.isSynced = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

  // Convert Task to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'tags': tags,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Create a Task from Firebase data
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      isSynced: true,
    );
  }

  // Create a copy of the task with updated fields
  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    List<String>? tags,
    bool? isSynced,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? List.from(this.tags),
      isSynced: isSynced ?? this.isSynced,
    );
  }
} 