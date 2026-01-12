import '../rdbms/db_engine.dart';
import '../rdbms/sql_parser.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'demo_data_service.dart';
import 'data_persistence_service.dart';

class DbController with ChangeNotifier {
  final DbEngine _engine = DbEngine();
  late final SqlParser _parser;
  final List<String> _commandHistory = <String>[];
  final List<String> _outputHistory = <String>[];

  DbController() {
    _parser = SqlParser(_engine);
    // Load any saved data asynchronously
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    // Wait for data to be loaded before continuing
    await _loadSavedData();
    
    // Initialize with demo data only if no saved data
    if (_engine.getTableNames().isEmpty) {
      DemoDataService.populateDemoData(_engine);
      // Make sure to save the demo data after loading it
      await saveData();
    }
    
    // Notify any listeners that initialization is complete
    notifyListeners();
  }
  
  Future<void> _loadSavedData() async {
    await DataPersistenceService.loadDatabase(_engine);
  }
  
  Future<void> saveData() async {
    await DataPersistenceService.saveDatabase(_engine);
  }
  
  Future<void> clearSavedData() async {
    await DataPersistenceService.clearSavedData();
  }

  List<String> get commandHistory => List.unmodifiable(_commandHistory);
  List<String> get outputHistory => List.unmodifiable(_outputHistory);

  // Execute a SQL command
  void executeCommand(String command) {
    _commandHistory.add(command);
    
    try {
      final result = _parser.parseCommand(command);
      
      // Ensure result is a Map before accessing it
      if (result is! Map) {
        _outputHistory.add("Error: Unexpected result format from parser: ${result.runtimeType}");
        notifyListeners();
        return;
      }
      
      // Check if success is true (explicitly true, not just truthy)
      if (result['success'] == true) {
        if (result.containsKey('data')) {
          // For SELECT and JOIN commands that return data
          final data = result['data'] as List;
          if (data.isEmpty) {
            _outputHistory.add("Query executed successfully. No rows returned.");
          } else {
            // Format the data nicely
            _outputHistory.add("Query executed successfully. ${data.length} row(s) returned:");
            for (final row in data) {
              _outputHistory.add("  ${row.toString()}");
            }
          }
        } else {
          // For other commands (INSERT, UPDATE, DELETE, CREATE)
          _outputHistory.add(result['message'] ?? "Command executed successfully");
        }
      } else {
        // Error occurred - provide more detailed error info if available
        String errorMessage = result['error'];
        if (errorMessage == null) {
          // Check if there's a message field we can use
          String message = result['message'];
          if (message != null) {
            errorMessage = message;
          } else {
            errorMessage = 'Unknown error - parser returned: ${result.toString()}';
          }
        }
        _outputHistory.add("Error: $errorMessage");
      }
    } catch (e) {
      _outputHistory.add("Error: ${e.toString()}");
    }
    
    notifyListeners();
    // Save data after command execution
    saveData();
  }
  
  // Execute a SQL command directly (without adding the command to output history)
  void executeCommandDirect(String command) {
    try {
      final result = _parser.parseCommand(command);
      
      // Ensure result is a Map before accessing it
      if (result is! Map) {
        _outputHistory.add("Error: Unexpected result format from parser: ${result.runtimeType}");
        notifyListeners();
        return;
      }
      
      // Handle special system commands
      if (result.containsKey('command')) {
        String sysCommand = result['command'];
        String message = result['message'];
        
        switch(sysCommand) {
          case 'clear':
            _outputHistory.clear();
            _outputHistory.add('Screen cleared.');
            notifyListeners();
            return;
          case 'history':
            _outputHistory.add('Command history:');
            for (int i = 0; i < _commandHistory.length; i++) {
              _outputHistory.add('  ${i + 1}. ${_commandHistory[i]}');
            }
            notifyListeners();
            return;
          case 'exit':
            _outputHistory.add('Exiting application...');
            notifyListeners();
            return;
        }
      }
      
      // Check if success is true (explicitly true, not just truthy)
      if (result['success'] == true) {
        if (result.containsKey('data')) {
          // For SELECT and JOIN commands that return data
          final data = result['data'] as List;
          if (data.isEmpty) {
            _outputHistory.add("Query executed successfully. No rows returned.");
          } else {
            // Format the data nicely
            _outputHistory.add("Query executed successfully. ${data.length} row(s) returned:");
            for (final row in data) {
              _outputHistory.add("  ${row.toString()}");
            }
          }
        } else {
          // For other commands (INSERT, UPDATE, DELETE, CREATE)
          _outputHistory.add(result['message'] ?? "Command executed successfully");
        }
      } else {
        // Error occurred - provide more detailed error info if available
        String errorMessage = result['error'];
        if (errorMessage == null) {
          // Check if there's a message field we can use
          String message = result['message'];
          if (message != null) {
            errorMessage = message;
          } else {
            errorMessage = 'Unknown error - parser returned: ${result.toString()}';
          }
        }
        _outputHistory.add("Error: $errorMessage");
      }
    } catch (e) {
      _outputHistory.add("Error: ${e.toString()}");
    }
    
    notifyListeners();
    // Save data after command execution
    saveData();
  }

  // Add output directly to the output history
  void addToOutput(String output) {
    _outputHistory.add(output);
    notifyListeners();
  }

  // Get all table names
  List<String> getTableNames() {
    return _engine.getTableNames();
  }

  // Get data from a specific table
  List<Map<String, dynamic>> getTableData(String tableName) {
    return _engine.select(tableName);
  }

  // Clear history
  void clearHistory() {
    _commandHistory.clear();
    _outputHistory.clear();
    notifyListeners();
  }
}