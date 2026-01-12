import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[900],
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'pesapal-rdbms Commands',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Command Reference',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Commands List
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCommandSection('Database Commands', [
                        {
                          'command': 'SHOW TABLES',
                          'description': 'List all tables in the database',
                        },
                        {
                          'command': 'DESCRIBE table_name',
                          'description':
                              'Show table structure with column details',
                        },
                        {
                          'command': 'DESC table_name',
                          'description': 'Alternative to DESCRIBE command',
                        },
                      ], context),

                      _buildCommandSection('Data Manipulation Commands (DML)', [
                        {
                          'command': 'CREATE TABLE name (col type constraints)',
                          'description':
                              'Create a new table with specified columns',
                        },
                        {
                          'command': 'DROP TABLE name',
                          'description': 'Delete a table and all its data',
                        },
                        {
                          'command': 'INSERT INTO table (cols) VALUES (values)',
                          'description': 'Add new records to a table',
                        },
                        {
                          'command': 'SELECT * FROM table',
                          'description': 'Retrieve all records from a table',
                        },
                        {
                          'command': 'SELECT * FROM table WHERE condition',
                          'description': 'Filter records based on condition',
                        },
                        {
                          'command': 'UPDATE table SET col=val WHERE condition',
                          'description': 'Modify existing records',
                        },
                        {
                          'command': 'DELETE FROM table WHERE condition',
                          'description': 'Remove records that match condition',
                        },
                      ], context),

                      _buildCommandSection('Join Operations', [
                        {
                          'command':
                              'JOIN table1 WITH table2 ON t1.col = t2.col',
                          'description':
                              'Perform inner join between two tables',
                        },
                      ], context),

                      _buildCommandSection('System Commands', [
                        {
                          'command': 'clear',
                          'description': 'Clear the terminal screen',
                        },
                        {
                          'command': 'cls',
                          'description': 'Alternative to clear command',
                        },
                        {
                          'command': 'help',
                          'description': 'Show this help message',
                        },
                        {
                          'command': 'man',
                          'description': 'Alternative to help command',
                        },
                        {'command': '?', 'description': 'Quick help command'},
                        {
                          'command': 'history',
                          'description': 'Show command history',
                        },
                        {
                          'command': 'hist',
                          'description': 'Alternative to history command',
                        },
                        {'command': 'exit', 'description': 'Exit the terminal'},
                        {
                          'command': 'quit',
                          'description': 'Alternative to exit command',
                        },
                        {'command': 'q', 'description': 'Quick exit command'},
                      ], context),

                      const SizedBox(height: 32),

                      // Welcome message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome to pesapal-rdbms!',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This is a lightweight RDBMS terminal emulator supporting standard SQL commands and Linux-style utilities. All data is persisted between sessions.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(text: 'Examples: '),
                                  TextSpan(
                                    text: 'SELECT * FROM users;',
                                    style: TextStyle(
                                      color: Colors.cyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: '\n'),
                                  TextSpan(
                                    text:
                                        'CREATE TABLE employees (id int primary key, name string);',
                                    style: TextStyle(
                                      color: Colors.cyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: '\n'),
                                  TextSpan(
                                    text:
                                        'JOIN users WITH orders ON users.id = orders.user_id;',
                                    style: TextStyle(
                                      color: Colors.cyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandSection(
    String title,
    List<Map<String, String>> commands,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...commands
              .map(
                (cmd) => _buildCommandItem(
                  cmd['command']!,
                  cmd['description']!,
                  context,
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCommandItem(
    String command,
    String description,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            command,
            style: const TextStyle(
              color: Colors.cyan,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
