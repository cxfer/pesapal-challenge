import 'lib/rdbms/db_engine.dart';
import 'lib/rdbms/sql_parser.dart';

void main() {
  print("=== Testing SQL Parser ===");
  
  final db = DbEngine();
  final parser = SqlParser(db);
  
  // Test CREATE TABLE
  print("\n1. Testing CREATE TABLE:");
  var result = parser.parseCommand("CREATE TABLE users (id int primary key, name string, email string unique)");
  print(result);
  
  result = parser.parseCommand("CREATE TABLE products (id int primary key, name string, price double)");
  print(result);
  
  result = parser.parseCommand("CREATE TABLE orders (id int primary key, user_id int, product_id int, quantity int)");
  print(result);
  
  // Test INSERT
  print("\n2. Testing INSERT:");
  result = parser.parseCommand("INSERT INTO users (id, name, email) VALUES (1, 'John Doe', 'john@example.com')");
  print(result);
  
  result = parser.parseCommand("INSERT INTO users (id, name, email) VALUES (2, 'Jane Smith', 'jane@example.com')");
  print(result);
  
  result = parser.parseCommand("INSERT INTO products (id, name, price) VALUES (1, 'Laptop', 999.99)");
  print(result);
  
  result = parser.parseCommand("INSERT INTO products (id, name, price) VALUES (2, 'Mouse', 29.99)");
  print(result);
  
  result = parser.parseCommand("INSERT INTO orders (id, user_id, product_id, quantity) VALUES (1, 1, 1, 1)");
  print(result);
  
  result = parser.parseCommand("INSERT INTO orders (id, user_id, product_id, quantity) VALUES (2, 2, 2, 3)");
  print(result);
  
  // Test SELECT
  print("\n3. Testing SELECT:");
  result = parser.parseCommand("SELECT * FROM users");
  print("Users:");
  if (result['success']) {
    for (var row in result['data']) {
      print("  $row");
    }
  }
  
  result = parser.parseCommand("SELECT * FROM products");
  print("Products:");
  if (result['success']) {
    for (var row in result['data']) {
      print("  $row");
    }
  }
  
  result = parser.parseCommand("SELECT * FROM users WHERE id = 1");
  print("User with id=1:");
  if (result['success']) {
    for (var row in result['data']) {
      print("  $row");
    }
  }
  
  // Test UPDATE
  print("\n4. Testing UPDATE:");
  result = parser.parseCommand("UPDATE users SET name = 'John Updated' WHERE id = 1");
  print(result);
  
  // Verify update worked
  result = parser.parseCommand("SELECT * FROM users WHERE id = 1");
  print("Updated user:");
  if (result['success']) {
    for (var row in result['data']) {
      print("  $row");
    }
  }
  
  // Test DELETE
  print("\n5. Testing DELETE:");
  result = parser.parseCommand("DELETE FROM users WHERE id = 2");
  print(result);
  
  // Verify delete worked
  result = parser.parseCommand("SELECT * FROM users");
  print("Users after deletion:");
  if (result['success']) {
    for (var row in result['data']) {
      print("  $row");
    }
  }
  
  // Test JOIN
  print("\n6. Testing JOIN:");
  result = parser.parseCommand("JOIN users WITH orders ON users.id = orders.user_id");
  print("Users JOIN Orders:");
  if (result['success']) {
    for (var row in result['data']) {
      print("  $row");
    }
  }
  
  result = parser.parseCommand("JOIN orders WITH products ON orders.product_id = products.id");
  print("Orders JOIN Products:");
  if (result['success']) {
    for (var row in result['data']) {
      print("  $row");
    }
  }
  
  print("\n=== SQL Parser Tests Completed ===\n");
}