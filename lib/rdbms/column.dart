/// Represents a column in a database table
class Column {
  final String name;
  final String type;  // 'int', 'string', 'double', etc.
  final bool primaryKey;
  final bool unique;
  final bool nullable;

  Column({
    required this.name,
    required this.type,
    this.primaryKey = false,
    this.unique = false,
    this.nullable = true,
  });

  @override
  String toString() {
    return 'Column{name: $name, type: $type, primaryKey: $primaryKey, unique: $unique, nullable: $nullable}';
  }
}