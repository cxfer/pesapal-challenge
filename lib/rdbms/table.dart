import 'column.dart';

/// Represents a database table with name, columns, and rows
class Table {
  final String name;
  final List<Column> columns;
  final List<Map<String, dynamic>> rows;
  final Map<String, Column> columnMap;

  Table({
    required this.name,
    required this.columns,
  }) : 
    rows = [],
    columnMap = {} {
      // Initialize column map for quick lookup
      for (final column in columns) {
        columnMap[column.name] = column;
      }
    }

  /// Get primary key column if exists
  Column? get primaryKeyColumn {
    try {
      return columns.firstWhere((column) => column.primaryKey);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'Table{name: $name, columns: $columns, rows: ${rows.length}}';
  }
}