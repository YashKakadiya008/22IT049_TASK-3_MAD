import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskflow_voice_todo/models/task.dart';
import 'package:taskflow_voice_todo/models/voice_command.dart';
import 'package:taskflow_voice_todo/screens/home_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await _initializeHive();
  
  // Run the app with Riverpod for state management
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> _initializeHive() async {
  // Initialize Hive for web
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(VoiceCommandAdapter());
  Hive.registerAdapter(CommandTypeAdapter());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow Voice Todo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Hive type adapters
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;
  
  @override
  Task read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasDueDate = reader.readBool();
    final dueDate = hasDueDate 
        ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) 
        : null;
    final isCompleted = reader.readBool();
    final tagsLength = reader.readInt();
    final tags = List<String>.generate(tagsLength, (_) => reader.readString());
    final isSynced = reader.readBool();
    
    return Task(
      id: id,
      title: title,
      description: description.isEmpty ? null : description,
      createdAt: createdAt,
      dueDate: dueDate,
      isCompleted: isCompleted,
      tags: tags,
      isSynced: isSynced,
    );
  }
  
  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description ?? '');
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.dueDate != null);
    if (obj.dueDate != null) {
      writer.writeInt(obj.dueDate!.millisecondsSinceEpoch);
    }
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.tags.length);
    for (final tag in obj.tags) {
      writer.writeString(tag);
    }
    writer.writeBool(obj.isSynced);
  }
}

class CommandTypeAdapter extends TypeAdapter<CommandType> {
  @override
  final int typeId = 2;
  
  @override
  CommandType read(BinaryReader reader) {
    return CommandType.values[reader.readInt()];
  }
  
  @override
  void write(BinaryWriter writer, CommandType obj) {
    writer.writeInt(obj.index);
  }
}

class VoiceCommandAdapter extends TypeAdapter<VoiceCommand> {
  @override
  final int typeId = 1;
  
  @override
  VoiceCommand read(BinaryReader reader) {
    final id = reader.readString();
    final rawText = reader.readString();
    final type = CommandType.values[reader.readInt()];
    final Map<String, dynamic> parameters = {};
    final parametersLength = reader.readInt();
    for (var i = 0; i < parametersLength; i++) {
      final key = reader.readString();
      final valueType = reader.readInt();
      switch (valueType) {
        case 0: // String
          parameters[key] = reader.readString();
          break;
        case 1: // int
          parameters[key] = reader.readInt();
          break;
        case 2: // double
          parameters[key] = reader.readDouble();
          break;
        case 3: // bool
          parameters[key] = reader.readBool();
          break;
        case 4: // DateTime
          parameters[key] = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
          break;
        case 5: // List<String>
          final listLength = reader.readInt();
          final list = List<String>.generate(listLength, (_) => reader.readString());
          parameters[key] = list;
          break;
      }
    }
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final isProcessed = reader.readBool();
    
    return VoiceCommand(
      id: id,
      rawText: rawText,
      type: type,
      parameters: parameters,
      timestamp: timestamp,
      isProcessed: isProcessed,
    );
  }
  
  @override
  void write(BinaryWriter writer, VoiceCommand obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.rawText);
    writer.writeInt(obj.type.index);
    writer.writeInt(obj.parameters.length);
    
    obj.parameters.forEach((key, value) {
      writer.writeString(key);
      if (value is String) {
        writer.writeInt(0);
        writer.writeString(value);
      } else if (value is int) {
        writer.writeInt(1);
        writer.writeInt(value);
      } else if (value is double) {
        writer.writeInt(2);
        writer.writeDouble(value);
      } else if (value is bool) {
        writer.writeInt(3);
        writer.writeBool(value);
      } else if (value is DateTime) {
        writer.writeInt(4);
        writer.writeInt(value.millisecondsSinceEpoch);
      } else if (value is List<String>) {
        writer.writeInt(5);
        writer.writeInt(value.length);
        for (final item in value) {
          writer.writeString(item);
        }
      }
    });
    
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.isProcessed);
  }
}
