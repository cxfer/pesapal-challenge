import 'lib/rdbms/db_engine.dart';
import 'lib/rdbms/sql_parser.dart';
import 'lib/ui/demo_data_service.dart';

void main() {
  print("=== Debug SQL Parser ===");
  
  final db = DbEngine();
  final parser = SqlParser(db);
  
  // Initialize with demo data
  DemoDataService.populateDemoData(db);
  
  // Test various commands
  List<String> testCommands = [
    "SELECT * FROM users",
    "SELECT * FROM users WHERE id = 1", 
    "INSERT INTO users (id, name, email, age) VALUES (6, 'Test User', 'test@example.com', 25)",
    "UPDATE users SET name = 'Updated Name' WHERE id = 1",
    "DELETE FROM users WHERE id = 6",
    "JOIN users WITH orders ON users.id = orders.user_id",
    "CREATE TABLE test (id int primary key, name string)",
    "INVALID COMMAND"
  ];
  
  for (String command in testCommands) {
    print("\nTesting command: '$command'");
    try {
      var result = parser.parseCommand(command);
      print("Result: $result");
      
      if (result is Map) {
        print("  - success: ${result['success']}");
        print("  - error: ${result['error']}");
        print("  - message: ${result['message']}");
        print("  - data: ${result['data']}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }
  
  print("\n=== Debug Complete ===");
}