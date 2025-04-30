import 'package:taskflow_voice_todo/models/voice_command.dart';

class CommandParserService {
  // Parse raw text into a structured command
  VoiceCommand parseCommand(String rawText) {
    final text = rawText.toLowerCase().trim();
    
    // Check for add task commands
    if (_isAddTaskCommand(text)) {
      return _parseAddTaskCommand(text);
    }
    
    // Check for complete task commands
    if (_isCompleteTaskCommand(text)) {
      return _parseCompleteTaskCommand(text);
    }
    
    // Check for delete task commands
    if (_isDeleteTaskCommand(text)) {
      return _parseDeleteTaskCommand(text);
    }
    
    // Check for update task commands
    if (_isUpdateTaskCommand(text)) {
      return _parseUpdateTaskCommand(text);
    }
    
    // Check for query tasks commands
    if (_isQueryTasksCommand(text)) {
      return _parseQueryTasksCommand(text);
    }
    
    // Default to unknown command type
    return VoiceCommand(
      rawText: rawText,
      type: CommandType.unknown,
    );
  }
  
  // Detect add task commands
  bool _isAddTaskCommand(String text) {
    return text.contains('add task') || 
           text.contains('create task') || 
           text.contains('new task') ||
           text.contains('add to do') ||
           text.contains('create to do');
  }
  
  // Parse add task command
  VoiceCommand _parseAddTaskCommand(String text) {
    final parameters = <String, dynamic>{};
    
    // Extract task title (everything after "add task", "create task", etc.)
    String taskTitle = '';
    
    if (text.contains('add task')) {
      taskTitle = text.substring(text.indexOf('add task') + 'add task'.length).trim();
    } else if (text.contains('create task')) {
      taskTitle = text.substring(text.indexOf('create task') + 'create task'.length).trim();
    } else if (text.contains('new task')) {
      taskTitle = text.substring(text.indexOf('new task') + 'new task'.length).trim();
    } else if (text.contains('add to do')) {
      taskTitle = text.substring(text.indexOf('add to do') + 'add to do'.length).trim();
    } else if (text.contains('create to do')) {
      taskTitle = text.substring(text.indexOf('create to do') + 'create to do'.length).trim();
    }
    
    parameters['title'] = taskTitle;
    
    // Extract due date if mentioned
    if (text.contains('due') || text.contains('by')) {
      // Simple date extraction for common phrases
      // More sophisticated date parsing would be needed for a production app
      if (text.contains('today')) {
        parameters['dueDate'] = DateTime.now();
      } else if (text.contains('tomorrow')) {
        parameters['dueDate'] = DateTime.now().add(const Duration(days: 1));
      } else if (text.contains('next week')) {
        parameters['dueDate'] = DateTime.now().add(const Duration(days: 7));
      }
    }
    
    // Extract tags if mentioned
    if (text.contains('tag') || text.contains('category')) {
      final List<String> tags = [];
      
      // Simple tag extraction
      if (text.contains('tag it as') || text.contains('category')) {
        final tagStart = text.contains('tag it as') 
            ? text.indexOf('tag it as') + 'tag it as'.length 
            : text.indexOf('category') + 'category'.length;
            
        final tagText = text.substring(tagStart).trim();
        tags.add(tagText);
      }
      
      if (tags.isNotEmpty) {
        parameters['tags'] = tags;
      }
    }
    
    return VoiceCommand(
      rawText: text,
      type: CommandType.addTask,
      parameters: parameters,
    );
  }
  
  // Detect complete task commands
  bool _isCompleteTaskCommand(String text) {
    return text.contains('complete task') || 
           text.contains('mark task as done') ||
           text.contains('mark as complete') ||
           text.contains('finish task');
  }
  
  // Parse complete task command
  VoiceCommand _parseCompleteTaskCommand(String text) {
    final parameters = <String, dynamic>{};
    
    // Extract task identifier from the command
    String taskIdentifier = '';
    
    if (text.contains('complete task')) {
      taskIdentifier = text.substring(text.indexOf('complete task') + 'complete task'.length).trim();
    } else if (text.contains('mark task as done')) {
      taskIdentifier = text.substring(text.indexOf('mark task as done') + 'mark task as done'.length).trim();
    } else if (text.contains('mark as complete')) {
      taskIdentifier = text.substring(text.indexOf('mark as complete') + 'mark as complete'.length).trim();
    } else if (text.contains('finish task')) {
      taskIdentifier = text.substring(text.indexOf('finish task') + 'finish task'.length).trim();
    }
    
    parameters['taskIdentifier'] = taskIdentifier;
    
    return VoiceCommand(
      rawText: text,
      type: CommandType.completeTask,
      parameters: parameters,
    );
  }
  
  // Detect delete task commands
  bool _isDeleteTaskCommand(String text) {
    return text.contains('delete task') || 
           text.contains('remove task') ||
           text.contains('delete to do');
  }
  
  // Parse delete task command
  VoiceCommand _parseDeleteTaskCommand(String text) {
    final parameters = <String, dynamic>{};
    
    // Extract task identifier from the command
    String taskIdentifier = '';
    
    if (text.contains('delete task')) {
      taskIdentifier = text.substring(text.indexOf('delete task') + 'delete task'.length).trim();
    } else if (text.contains('remove task')) {
      taskIdentifier = text.substring(text.indexOf('remove task') + 'remove task'.length).trim();
    } else if (text.contains('delete to do')) {
      taskIdentifier = text.substring(text.indexOf('delete to do') + 'delete to do'.length).trim();
    }
    
    parameters['taskIdentifier'] = taskIdentifier;
    
    return VoiceCommand(
      rawText: text,
      type: CommandType.deleteTask,
      parameters: parameters,
    );
  }
  
  // Detect update task commands
  bool _isUpdateTaskCommand(String text) {
    return text.contains('update task') || 
           text.contains('change task') ||
           text.contains('modify task') ||
           text.contains('rename task');
  }
  
  // Parse update task command
  VoiceCommand _parseUpdateTaskCommand(String text) {
    final parameters = <String, dynamic>{};
    
    // Extract task identifier and new details from the command
    String taskIdentifier = '';
    
    if (text.contains('update task')) {
      taskIdentifier = text.substring(text.indexOf('update task') + 'update task'.length).trim();
    } else if (text.contains('change task')) {
      taskIdentifier = text.substring(text.indexOf('change task') + 'change task'.length).trim();
    } else if (text.contains('modify task')) {
      taskIdentifier = text.substring(text.indexOf('modify task') + 'modify task'.length).trim();
    } else if (text.contains('rename task')) {
      taskIdentifier = text.substring(text.indexOf('rename task') + 'rename task'.length).trim();
    }
    
    parameters['taskIdentifier'] = taskIdentifier;
    
    // Check for specific update types
    if (text.contains('to') && text.indexOf('to') > text.indexOf('task')) {
      final newValue = text.substring(text.indexOf('to') + 2).trim();
      parameters['newValue'] = newValue;
    }
    
    // Check for due date updates
    if (text.contains('due date') || text.contains('deadline')) {
      parameters['updateType'] = 'dueDate';
      
      // Simple date extraction
      if (text.contains('today')) {
        parameters['newDueDate'] = DateTime.now();
      } else if (text.contains('tomorrow')) {
        parameters['newDueDate'] = DateTime.now().add(const Duration(days: 1));
      } else if (text.contains('next week')) {
        parameters['newDueDate'] = DateTime.now().add(const Duration(days: 7));
      }
    }
    
    return VoiceCommand(
      rawText: text,
      type: CommandType.updateTask,
      parameters: parameters,
    );
  }
  
  // Detect query tasks commands
  bool _isQueryTasksCommand(String text) {
    return text.contains('show tasks') || 
           text.contains('list tasks') ||
           text.contains('find tasks') ||
           text.contains('search tasks') ||
           text.contains('show to do');
  }
  
  // Parse query tasks command
  VoiceCommand _parseQueryTasksCommand(String text) {
    final parameters = <String, dynamic>{};
    
    // Detect query type
    if (text.contains('today')) {
      parameters['timeFilter'] = 'today';
    } else if (text.contains('this week')) {
      parameters['timeFilter'] = 'week';
    } else if (text.contains('completed') || text.contains('done')) {
      parameters['statusFilter'] = 'completed';
    } else if (text.contains('pending') || text.contains('not done')) {
      parameters['statusFilter'] = 'pending';
    }
    
    // Look for tag filters
    if (text.contains('tag') || text.contains('category')) {
      final tagIndex = text.contains('tag') ? text.indexOf('tag') : text.indexOf('category');
      final tagText = text.substring(tagIndex).trim();
      parameters['tagFilter'] = tagText;
    }
    
    return VoiceCommand(
      rawText: text,
      type: CommandType.queryTasks,
      parameters: parameters,
    );
  }
} 