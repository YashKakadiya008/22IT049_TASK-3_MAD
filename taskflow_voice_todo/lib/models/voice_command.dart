import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'voice_command.g.dart';

enum CommandType {
  addTask,
  completeTask,
  deleteTask,
  updateTask,
  queryTasks,
  unknown
}

@HiveType(typeId: 1)
class VoiceCommand {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String rawText;

  @HiveField(2)
  final CommandType type;

  @HiveField(3)
  final Map<String, dynamic> parameters;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  bool isProcessed;

  VoiceCommand({
    String? id,
    required this.rawText,
    required this.type,
    Map<String, dynamic>? parameters,
    DateTime? timestamp,
    this.isProcessed = false,
  })  : id = id ?? const Uuid().v4(),
        parameters = parameters ?? {},
        timestamp = timestamp ?? DateTime.now();

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rawText': rawText,
      'type': type.index,
      'parameters': parameters,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isProcessed': isProcessed,
    };
  }

  // Create from Map
  factory VoiceCommand.fromMap(Map<String, dynamic> map) {
    return VoiceCommand(
      id: map['id'],
      rawText: map['rawText'],
      type: CommandType.values[map['type']],
      parameters: Map<String, dynamic>.from(map['parameters'] ?? {}),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isProcessed: map['isProcessed'] ?? false,
    );
  }

  // Create a copy with updated fields
  VoiceCommand copyWith({
    bool? isProcessed,
  }) {
    return VoiceCommand(
      id: this.id,
      rawText: this.rawText,
      type: this.type,
      parameters: Map<String, dynamic>.from(this.parameters),
      timestamp: this.timestamp,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
} 