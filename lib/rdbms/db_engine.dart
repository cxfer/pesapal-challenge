import 'table.dart';
import 'column.dart';

/// Main database engine class
class DbEngine {
  final Map<String, Table> _tables = {};
  final Map<String, Map<dynamic, Map<String, dynamic>>> _primaryIndex = {};

  /// Create a new table
  bool createTable(String name, List<Column> columns) {
    if (_tables.containsKey(name)) {
      print("Error: Table '$name' already exists");
      return false;
    }

    // Validate that there's at most one primary key
    int primaryKeyCount = columns.where((col) => col.primaryKey).length;
    if (primaryKeyCount > 1) {
      print("Error: Table '$name' has multiple primary key columns");
      return false;
    }

    final table = Table(name: name, columns: columns);
    _tables[name] = table;

    // Initialize primary index for this table if it has a primary key
    if (table.primaryKeyColumn != null) {
      _primaryIndex[name] = {};
    }

    print("Table '$name' created successfully");
    return true;
  }

  /// Insert a new row into a table
  bool insertRow(String tableName, Map<String, dynamic> row) {
    final table = _tables[tableName];
    if (table == null) {
      print("Error: Table '$tableName' does not exist");
      return false;
    }

    // Validate columns
    for (final entry in row.entries) {
      if (!table.columnMap.containsKey(entry.key)) {
        print(
          "Error: Column '${entry.key}' does not exist in table '$tableName'",
        );
        return false;
      }
    }

    // Check primary key and unique constraints
    final primaryKeyCol = table.primaryKeyColumn;
    if (primaryKeyCol != null && row.containsKey(primaryKeyCol.name)) {
      final primaryKeyValue = row[primaryKeyCol.name];

      // Check if primary key already exists
      if (_primaryIndex[tableName]!.containsKey(primaryKeyValue)) {
        print(
          "Error: Primary key '${primaryKeyCol.name}' with value '$primaryKeyValue' already exists",
        );
        return false;
      }

      // Check unique constraints
      for (final column in table.columns) {
        if (column.unique && row.containsKey(column.name)) {
          final value = row[column.name];
          // Look for duplicate in existing rows
          for (final existingRow in table.rows) {
            if (existingRow[column.name] == value && value != null) {
              print(
                "Error: Unique constraint violation for column '${column.name}' with value '$value'",
              );
              return false;
            }
          }
        }
      }

      // Add to primary index
      _primaryIndex[tableName]![primaryKeyValue] = row;
    }

    table.rows.add(
      Map.from(row),
    ); // Make a copy to avoid external modifications
    print("Row inserted into table '$tableName' successfully");
    return true;
  }

  /// Select rows from a table with optional filters
  List<Map<String, dynamic>> select(
    String tableName, [
    Map<String, dynamic>? filters,
  ]) {
    final table = _tables[tableName];
    if (table == null) {
      print("Error: Table '$tableName' does not exist");
      return [];
    }

    List<Map<String, dynamic>> result = List.from(table.rows);

    if (filters != null) {
      result = result.where((row) {
        for (final filter in filters.entries) {
          if (!row.containsKey(filter.key) || row[filter.key] != filter.value) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    return result;
  }

  

  /// Update rows in a table based on filters
  int updateRow(
    String tableName,
    Map<String, dynamic> filters,
    Map<String, dynamic> newValues,
  ) {
    final table = _tables[tableName];
    if (table == null) {
      print("Error: Table '$tableName' does not exist");
      return 0;
    }

    int updatedCount = 0;

    for (int i = 0; i < table.rows.length; i++) {
      bool matchesFilters = true;

      // Check if row matches all filters
      for (final filter in filters.entries) {
        if (!table.rows[i].containsKey(filter.key) ||
            table.rows[i][filter.key] != filter.value) {
          matchesFilters = false;
          break;
        }
      }

      if (matchesFilters) {
        // Apply new values
        for (final newValue in newValues.entries) {
          table.rows[i][newValue.key] = newValue.value;
        }

        // Update primary index if primary key was modified
        final primaryKeyCol = table.primaryKeyColumn;
        if (primaryKeyCol != null &&
            newValues.containsKey(primaryKeyCol.name)) {
          final oldKeyValue = table.rows[i][primaryKeyCol.name];
          final newKeyValue = newValues[primaryKeyCol.name];

          // Remove old key from index
          _primaryIndex[tableName]!.remove(oldKeyValue);
          // Add new key to index
          _primaryIndex[tableName]![newKeyValue] = table.rows[i];
        }

        updatedCount++;
      }
    }

    print("$updatedCount row(s) updated in table '$tableName'");
    return updatedCount;
  }

  /// Delete rows from a table based on filters
  int deleteRow(String tableName, Map<String, dynamic> filters) {
    final table = _tables[tableName];
    if (table == null) {
      print("Error: Table '$tableName' does not exist");
      return 0;
    }

    int deletedCount = 0;
    final rowsToDelete = <int>[];

    // Find indices of rows to delete
    for (int i = 0; i < table.rows.length; i++) {
      bool matchesFilters = true;

      // Check if row matches all filters
      for (final filter in filters.entries) {
        if (!table.rows[i].containsKey(filter.key) ||
            table.rows[i][filter.key] != filter.value) {
          matchesFilters = false;
          break;
        }
      }

      if (matchesFilters) {
        rowsToDelete.add(i);

        // Remove from primary index if primary key exists
        final primaryKeyCol = table.primaryKeyColumn;
        if (primaryKeyCol != null) {
          final keyValue = table.rows[i][primaryKeyCol.name];
          _primaryIndex[tableName]!.remove(keyValue);
        }
      }
    }

    // Delete rows in reverse order to maintain indices
    for (int i = rowsToDelete.length - 1; i >= 0; i--) {
      table.rows.removeAt(rowsToDelete[i]);
    }

    deletedCount = rowsToDelete.length;
    print("$deletedCount row(s) deleted from table '$tableName'");
    return deletedCount;
  }

  /// Get all table names
  List<String> getTableNames() {
    return _tables.keys.toList();
  }

  /// Get a specific table
  Table? getTable(String name) {
    return _tables[name];
  }

  /// Drop a table
  bool dropTable(String name) {
    if (!_tables.containsKey(name)) {
      print("Error: Table '$name' does not exist");
      return false;
    }

    _tables.remove(name);
    _primaryIndex.remove(name);
    print("Table '$name' dropped successfully");
    return true;
  }

  /// Perform an inner join between two tables
  List<Map<String, dynamic>> joinTables(
    String table1Name,
    String table2Name,
    String key1,
    String key2,
  ) {
    final table1 = _tables[table1Name];
    final table2 = _tables[table2Name];

    if (table1 == null) {
      print("Error: Table '$table1Name' does not exist");
      return [];
    }

    if (table2 == null) {
      print("Error: Table '$table2' does not exist");
      return [];
    }

    // Verify that the join keys exist in their respective tables
    if (!table1.columnMap.containsKey(key1)) {
      print("Error: Column '$key1' does not exist in table '$table1Name'");
      return [];
    }

    if (!table2.columnMap.containsKey(key2)) {
      print("Error: Column '$key2' does not exist in table '$table2Name'");
      return [];
    }

    final result = <Map<String, dynamic>>[];

    // Perform the join
    for (final row1 in table1.rows) {
      final value1 = row1[key1];

      for (final row2 in table2.rows) {
        final value2 = row2[key2];

        if (value1 != null && value2 != null && value1 == value2) {
          // Combine the two rows, with table2 columns prefixed to avoid conflicts
          final joinedRow = <String, dynamic>{};

          // Add all columns from table1
          joinedRow.addAll(row1);

          // Add all columns from table2 with table prefix to avoid conflicts
          for (final entry in row2.entries) {
            final newKey = "${table2Name}_${entry.key}";
            joinedRow[newKey] = entry.value;
          }

          result.add(joinedRow);
        }
      }
    }

    return result;
  }

  /// Check if a table exists
  bool tableExists(String name) {
    return _tables.containsKey(name);
  }

  /// Get the number of rows in a table
  int getRowCount(String tableName) {
    final table = _tables[tableName];
    return table?.rows.length ?? 0;
  }

  /// Get all column names for a table
  List<String> getColumnNames(String tableName) {
    final table = _tables[tableName];
    return table?.columns.map((column) => column.name).toList() ?? [];
  }

  /// Clear all data (keeping table structures)
  void clear() {
    for (final table in _tables.values) {
      table.rows.clear();
    }
    _primaryIndex.clear();
    for (final tableName in _tables.keys) {
      final table = _tables[tableName]!;
      if (table.primaryKeyColumn != null) {
        _primaryIndex[tableName] = {};
      }
    }
  }
}
