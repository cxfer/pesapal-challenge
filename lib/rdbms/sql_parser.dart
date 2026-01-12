import 'db_engine.dart';
import 'column.dart';

class SqlParser {
  final DbEngine _engine;

  SqlParser(this._engine);

  /// Parse and execute SQL command
  dynamic parseCommand(String command) {
    command = command.trim().toLowerCase();

    if (command.startsWith('create table')) {
      return _parseCreateTable(command);
    } else if (command.startsWith('insert into')) {
      return _parseInsert(command);
    } else if (command.startsWith('select')) {
      return _parseSelect(command);
    } else if (command.startsWith('update')) {
      return _parseUpdate(command);
    } else if (command.startsWith('delete from')) {
      return _parseDelete(command);
    } else if (command.startsWith('join')) {
      return _parseJoin(command);
    } else if (command.startsWith('drop table')) {
      return _parseDropTable(command);
    } else if (command.startsWith('show tables')) {
      return _parseShowTables(command);
    } else if (command.startsWith('describe') || command.startsWith('desc')) {
      return _parseDescribe(command);
    } else if (command == 'clear' || command == 'cls' || command == 'clear screen') {
      return _parseClear(command);
    } else if (command == 'help' || command == 'man' || command == '?') {
      return _parseHelp(command);
    } else if (command == 'history' || command == 'hist') {
      return _parseHistory(command);
    } else if (command == 'exit' || command == 'quit' || command == 'q') {
      return _parseExit(command);
    } else {
      return {'error': 'Unknown command: $command'};
    }
  }

  /// Parse CREATE TABLE command
  dynamic _parseCreateTable(String command) {
    // Pattern: CREATE TABLE table_name (col1 type1, col2 type2, ...)
    final regex = RegExp(r'create table (\w+) \((.+)\)', caseSensitive: false);
    final match = regex.firstMatch(command);
    
    if (match == null) {
      return {'error': 'Invalid CREATE TABLE syntax'};
    }

    final tableName = match.group(1)!;
    final columnsStr = match.group(2)!;

    // Parse columns: name type constraints
    final columnRegex = RegExp(r'(\w+)\s+(\w+)(?:\s+(primary\s+key|unique))?');
    final columnMatches = columnRegex.allMatches(columnsStr);

    final columns = <Column>[];
    for (final match in columnMatches) {
      final name = match.group(1)!;
      final type = match.group(2)!;
      final constraint = match.group(3);

      final column = Column(
        name: name,
        type: type.toLowerCase(),
        primaryKey: constraint != null && constraint.contains('primary'),
        unique: constraint != null && constraint.contains('unique'),
      );
      columns.add(column);
    }

    if (columns.isEmpty) {
      return {'error': 'No columns specified in CREATE TABLE'};
    }

    final success = _engine.createTable(tableName, columns);
    return {'success': success, 'message': success ? 'Table $tableName created' : 'Failed to create table $tableName'};
  }

  /// Parse INSERT INTO command
  dynamic _parseInsert(String command) {
    // Pattern: INSERT INTO table_name (col1, col2, ...) VALUES (val1, val2, ...)
    final regex = RegExp(r'insert into (\w+) \((.+)\) values \((.+)\)', caseSensitive: false);
    final match = regex.firstMatch(command);
    
    if (match == null) {
      return {'error': 'Invalid INSERT syntax'};
    }

    final tableName = match.group(1)!;
    final columnsStr = match.group(2)!;
    final valuesStr = match.group(3)!;

    // Split and clean column names
    final columns = columnsStr.split(',').map((s) => s.trim()).toList();
    // Split and clean values (handle quoted strings)
    final values = _parseValues(valuesStr);

    if (columns.length != values.length) {
      return {'error': 'Number of columns does not match number of values'};
    }

    // Create row map
    final row = <String, dynamic>{};
    for (int i = 0; i < columns.length; i++) {
      row[columns[i]] = values[i];
    }

    final success = _engine.insertRow(tableName, row);
    return {'success': success, 'message': success ? 'Row inserted into $tableName' : 'Failed to insert row into $tableName'};
  }

  /// Parse SELECT command
  dynamic _parseSelect(String command) {
    // Pattern: SELECT * FROM table_name WHERE condition
    final selectRegex = RegExp(r'select \* from (\w+)(?: where (.+))?', caseSensitive: false);
    final match = selectRegex.firstMatch(command);
    
    if (match == null) {
      return {'error': 'Invalid SELECT syntax'};
    }

    final tableName = match.group(1)!;
    final whereClause = match.group(2);

    if (whereClause != null && whereClause.isNotEmpty) {
      // Parse WHERE clause: column=value
      final filterRegex = RegExp(r'(\w+)\s*=\s*(.+)');
      final filterMatch = filterRegex.firstMatch(whereClause);
      
      if (filterMatch != null) {
        final col = filterMatch.group(1)!;
        final val = _parseSingleValue(filterMatch.group(2)!);
        
        final results = _engine.select(tableName, {col: val});
        return {'success': true, 'data': results};
      } else {
        return {'error': 'Invalid WHERE clause format'};
      }
    } else {
      // No WHERE clause - select all
      final results = _engine.select(tableName);
      return {'success': true, 'data': results};
    }
  }

  /// Parse UPDATE command
  dynamic _parseUpdate(String command) {
    // Pattern: UPDATE table_name SET col1=val1, col2=val2 WHERE condition
    final updateRegex = RegExp(r'update (\w+) set (.+) where (.+)', caseSensitive: false);
    final match = updateRegex.firstMatch(command);
    
    if (match == null) {
      return {'error': 'Invalid UPDATE syntax, requires WHERE clause'};
    }

    final tableName = match.group(1)!;
    final setClause = match.group(2)!;
    final whereClause = match.group(3)!;

    // Parse SET clause: col1=val1, col2=val2
    final setRegex = RegExp(r'(\w+)\s*=\s*([^,]+)');
    final setMatches = setRegex.allMatches(setClause);

    final newValues = <String, dynamic>{};
    for (final m in setMatches) {
      final col = m.group(1)!.trim();
      final val = _parseSingleValue(m.group(2)!.trim());
      newValues[col] = val;
    }

    // Parse WHERE clause: col=value
    final whereRegex = RegExp(r'(\w+)\s*=\s*(.+)');
    final whereMatch = whereRegex.firstMatch(whereClause);
    
    if (whereMatch == null) {
      return {'error': 'Invalid WHERE clause in UPDATE'};
    }

    final filterCol = whereMatch.group(1)!;
    final filterVal = _parseSingleValue(whereMatch.group(2)!.trim());

    final updatedCount = _engine.updateRow(tableName, {filterCol: filterVal}, newValues);
    return {'success': true, 'message': '$updatedCount row(s) updated in $tableName'};
  }

  /// Parse DELETE command
  dynamic _parseDelete(String command) {
    // Pattern: DELETE FROM table_name WHERE condition
    final deleteRegex = RegExp(r'delete from (\w+) where (.+)', caseSensitive: false);
    final match = deleteRegex.firstMatch(command);
    
    if (match == null) {
      return {'error': 'Invalid DELETE syntax, requires WHERE clause'};
    }

    final tableName = match.group(1)!;
    final whereClause = match.group(2)!;

    // Parse WHERE clause: col=value
    final whereRegex = RegExp(r'(\w+)\s*=\s*(.+)');
    final whereMatch = whereRegex.firstMatch(whereClause);
    
    if (whereMatch == null) {
      return {'error': 'Invalid WHERE clause in DELETE'};
    }

    final filterCol = whereMatch.group(1)!;
    final filterVal = _parseSingleValue(whereMatch.group(2)!.trim());

    final deletedCount = _engine.deleteRow(tableName, {filterCol: filterVal});
    return {'success': true, 'message': '$deletedCount row(s) deleted from $tableName'};
  }

  /// Parse JOIN command
  dynamic _parseJoin(String command) {
    // Pattern: JOIN table1 WITH table2 ON table1.col = table2.col
    final joinRegex = RegExp(r'join (\w+) with (\w+) on (\w+)\.(\w+) = (\w+)\.(\w+)', caseSensitive: false);
    final match = joinRegex.firstMatch(command);
    
    if (match == null) {
      return {'error': 'Invalid JOIN syntax. Expected: JOIN table1 WITH table2 ON table1.col = table2.col'};
    }

    final table1 = match.group(1)!;
    final table2 = match.group(2)!;
    final table1Name = match.group(3)!;
    final table1Col = match.group(4)!;
    final table2Name = match.group(5)!;
    final table2Col = match.group(6)!;

    // Verify the table names match what was provided
    if (table1 != table1Name || table2 != table2Name) {
      return {'error': 'Table names in ON clause do not match table names in JOIN'};
    }

    final results = _engine.joinTables(table1, table2, table1Col, table2Col);
    return {'success': true, 'data': results};
  }

  /// Helper to parse a single value (handling strings vs numbers)
  dynamic _parseSingleValue(String value) {
    value = value.trim();

    // Handle quoted strings
    if ((value.startsWith('"') && value.endsWith('"')) || 
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1); // Remove quotes
    }

    // Try to parse as integer
    try {
      return int.parse(value);
    } catch (e) {
      // Try to parse as double
      try {
        return double.parse(value);
      } catch (e) {
        // Return as string if neither works
        return value;
      }
    }
  }

  /// Helper to parse values string (handling strings vs numbers)
  List<dynamic> _parseValues(String valuesStr) {
    final values = <dynamic>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    String quoteChar = '';

    for (int i = 0; i < valuesStr.length; i++) {
      final char = valuesStr[i];

      if ((char == '"' || char == "'") && !inQuotes) {
        inQuotes = true;
        quoteChar = char;
        buffer.write(char);
      } else if (char == quoteChar && inQuotes) {
        inQuotes = false;
        buffer.write(char);
        quoteChar = '';
      } else if (char == ',' && !inQuotes) {
        values.add(_parseSingleValue(buffer.toString().trim()));
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      values.add(_parseSingleValue(buffer.toString().trim()));
    }

    return values;
  }

  /// Parse DROP TABLE command
  dynamic _parseDropTable(String command) {
    // Pattern: DROP TABLE table_name
    final regex = RegExp(r'drop table (\w+)', caseSensitive: false);
    final match = regex.firstMatch(command);
    
    if (match == null) {
      return {'error': 'Invalid DROP TABLE syntax'};
    }

    final tableName = match.group(1)!;
    
    final success = _engine.dropTable(tableName);
    
    if (success) {
      return {'success': true, 'message': 'Table $tableName dropped successfully'};
    } else {
      return {'error': 'Failed to drop table $tableName'};
    }
  }

  /// Parse SHOW TABLES command
  dynamic _parseShowTables(String command) {
    final tableNames = _engine.getTableNames();
    final tableData = tableNames.map((name) => {'table_name': name}).toList();
    return {'success': true, 'data': tableData, 'message': '${tableNames.length} table(s) found'};
  }

  /// Parse DESCRIBE/DESC command
  dynamic _parseDescribe(String command) {
    // Pattern: DESCRIBE table_name or DESC table_name
    final regex = RegExp(r'(describe|desc)\s+(\w+)', caseSensitive: false);
    final match = regex.firstMatch(command);
    
    if (match == null) {
      return {'error': 'Invalid DESCRIBE/DESC syntax'};
    }

    final tableName = match.group(2)!;
    final table = _engine.getTable(tableName);
    
    if (table == null) {
      return {'error': 'Table $tableName does not exist'};
    }

    final columnData = <Map<String, dynamic>>[];
    for (final column in table.columns) {
      columnData.add({
        'Field': column.name,
        'Type': column.type,
        'Null': column.nullable ? 'YES' : 'NO',
        'Key': column.primaryKey ? 'PRI' : (column.unique ? 'UNI' : ''),
        'Default': null,
        'Extra': '',
      });
    }

    return {
      'success': true,
      'data': columnData,
      'message': 'Table $tableName has ${table.columns.length} column(s)'
    };
  }

  /// Parse CLEAR command
  dynamic _parseClear(String command) {
    // This command would be handled by the UI, not the database engine
    // Return a special result that the UI can recognize
    return {'success': true, 'command': 'clear', 'message': 'clear_screen'};
  }

  /// Parse HELP command
  dynamic _parseHelp(String command) {
    final helpText = '''Available commands:

Database Commands:
  SHOW TABLES                    - List all tables
  DESCRIBE table_name            - Show table structure
  DESC table_name                - Alternative to DESCRIBE

SQL Commands:
  CREATE TABLE name (cols)       - Create a new table
  DROP TABLE name                - Delete a table
  INSERT INTO table (cols) VALUES (vals) - Add records
  SELECT * FROM table            - Retrieve all records
  SELECT * FROM table WHERE cond - Filter records
  UPDATE table SET col=val WHERE cond - Modify records
  DELETE FROM table WHERE cond   - Remove records
  JOIN table1 WITH table2 ON t1.col = t2.col - Join tables

System Commands:
  clear, cls                     - Clear the terminal
  help, man, ?                   - Show this help
  history, hist                  - Show command history
  exit, quit, q                  - Exit the terminal
    ''';
    return {'success': true, 'data': [{'help': helpText}], 'message': helpText};
  }

  /// Parse HISTORY command
  dynamic _parseHistory(String command) {
    // This would be handled by the UI
    return {'success': true, 'command': 'history', 'message': 'show_history'};
  }

  /// Parse EXIT command
  dynamic _parseExit(String command) {
    return {'success': true, 'command': 'exit', 'message': 'exit_application'};
  }
}