import 'package:flutter/material.dart';
import 'db_controller.dart';

class DataTableViewer extends StatefulWidget {
  final DbController controller;

  const DataTableViewer({Key? key, required this.controller}) : super(key: key);

  @override
  State<DataTableViewer> createState() => _DataTableViewerState();
}

class _DataTableViewerState extends State<DataTableViewer> {
  String _selectedTable = '';
  List<Map<String, dynamic>> _currentData = [];
  late List<String> _previousTableNames = [];

  @override
  void initState() {
    super.initState();
    _refreshTableList();
    // Listen to changes in the controller
    widget.controller.addListener(_handleControllerChange);
    // Store initial table names
    _previousTableNames = List.from(widget.controller.getTableNames());
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    // Check if table names have changed
    final currentTableNames = widget.controller.getTableNames();
    final hasTableChanged = _previousTableNames.length != currentTableNames.length ||
                           !_previousTableNames.every((table) => currentTableNames.contains(table)) ||
                           !currentTableNames.every((table) => _previousTableNames.contains(table));
    
    if (hasTableChanged) {
      _previousTableNames = List.from(currentTableNames);
      // Use WidgetsBinding to ensure the state update happens after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshTableList();
        }
      });
    }
  }

  void _refreshTableList() {
    final tables = widget.controller.getTableNames();
    if (tables.isNotEmpty) {
      // Check if the currently selected table still exists
      if (_selectedTable.isNotEmpty && tables.contains(_selectedTable)) {
        // Selected table still exists, just reload its data
        _loadTableData(_selectedTable);
      } else {
        // Either no table was selected or selected table no longer exists
        setState(() {
          _selectedTable = tables.first;
          _loadTableData(tables.first);
        });
      }
    } else {
      // No tables exist
      setState(() {
        _selectedTable = '';
        _currentData = [];
      });
    }
  }

  void _loadTableData(String tableName) {
    setState(() {
      _selectedTable = tableName;
      _currentData = widget.controller.getTableData(tableName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tables = widget.controller.getTableNames();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Database Tables'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Database Tables',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('Select Table: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedTable.isEmpty ? null : _selectedTable,
                        hint: const Text('Select a table'),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.black87),
                        dropdownColor: Colors.white,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _loadTableData(newValue);
                          }
                        },
                        items: tables.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _refreshTableList,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_currentData.isNotEmpty)
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dataTableTheme: DataTableThemeData(
                        headingRowColor: MaterialStateProperty.all<Color>(
                          Colors.grey[300]!,
                        ),
                        dataRowMinHeight: 40,
                        dataRowMaxHeight: 60,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 16,
                        columns: _currentData.first.keys.map((key) {
                          return DataColumn(
                            label: Text(
                              key,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        rows: _currentData.map((row) {
                          return DataRow(
                            cells: _currentData.first.keys.map((key) {
                              return DataCell(
                                Text(row[key]?.toString() ?? ''),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              )
            else if (_selectedTable.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_chart_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data in table "$_selectedTable"',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_rows_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tables available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}