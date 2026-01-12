import 'package:flutter/material.dart';
import 'ui/repl_screen.dart';
import 'ui/data_table_viewer.dart';
import 'ui/db_controller.dart';
import 'ui/help_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pesapal Mini-RDBMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DbController _controller = DbController();
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[];

  @override
  Widget build(BuildContext context) {
    // Dynamically create the list of screens
    final screens = [
      ReplScreen(),
      DataTableViewer(controller: _controller),
      const HelpScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesapal RDBMS'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.code),
            label: 'Console',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart),
            label: 'Tables',
          ),
          NavigationDestination(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}