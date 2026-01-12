import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../rdbms/db_engine.dart';
import '../rdbms/column.dart';
import '../rdbms/table.dart';

class DataPersistenceService {
  static const String _databaseKey = 'rdbms_database';
  static const String _schemaKey = 'rdbms_schema';

  // Save the entire database state
  static Future<void> saveDatabase(DbEngine engine) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Prepare data to save
      final dbData = <String, dynamic>{};
      final schemaData = <String, dynamic>{};
      
      final tableNames = engine.getTableNames();
      for (final tableName in tableNames) {
        final table = engine.getTable(tableName);
        if (table != null) {
          // Save table schema
          final columnsData = table.columns.map((column) => {
            'name': column.name,
            'type': column.type,
            'primaryKey': column.primaryKey,
            'unique': column.unique,
            'nullable': column.nullable,
          }).toList();
          
          schemaData[tableName] = {
            'columns': columnsData,
          };
          
          // Save table data
          dbData[tableName] = table.rows;
        }
      }
      
      // Store schema and data separately
      await prefs.setString(_schemaKey, jsonEncode(schemaData));
      await prefs.setString(_databaseKey, jsonEncode(dbData));
      
      print('Database saved successfully. Tables: ${tableNames.length}');
    } catch (e) {
      print('Error saving database: $e');
    }
  }

  // Load the database state
  static Future<void> loadDatabase(DbEngine engine) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final schemaJson = prefs.getString(_schemaKey);
      final dataJson = prefs.getString(_databaseKey);
      
      if (schemaJson == null || dataJson == null) {
        // No saved data, start fresh
        print('No saved data found, starting fresh');
        return;
      }
      
      final schemaData = jsonDecode(schemaJson) as Map<String, dynamic>;
      final dbData = jsonDecode(dataJson) as Map<String, dynamic>;
      
      // Recreate tables and their schemas
      for (final entry in schemaData.entries) {
        final tableName = entry.key;
        final tableSchema = entry.value as Map<String, dynamic>;
        final columnsData = tableSchema['columns'] as List<dynamic>;
        
        final columns = <Column>[];
        for (final colData in columnsData) {
          final col = colData as Map<String, dynamic>;
          columns.add(Column(
            name: col['name'] as String,
            type: col['type'] as String,
            primaryKey: col['primaryKey'] as bool,
            unique: col['unique'] as bool,
            nullable: col['nullable'] as bool,
          ));
        }
        
        // Create the table
        engine.createTable(tableName, columns);
        
        // Load the data if it exists
        if (dbData.containsKey(tableName)) {
          final tableData = dbData[tableName] as List<dynamic>;
          for (final rowData in tableData) {
            final row = rowData as Map<String, dynamic>;
            engine.insertRow(tableName, row);
          }
        }
      }
      
      print('Database loaded successfully. Tables: ${schemaData.length}');
    } catch (e) {
      // If there's an error loading, start fresh
      print('Error loading database: $e');
    }
  }

  // Clear saved data
  static Future<void> clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_schemaKey);
    await prefs.remove(_databaseKey);
    print('Saved data cleared');
  }
}