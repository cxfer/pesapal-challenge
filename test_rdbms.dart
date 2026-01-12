import 'lib/rdbms/db_engine.dart';
import 'lib/rdbms/column.dart';

void main() {
  print("=== Testing Database Engine ===");
  
  final db = DbEngine();
  
  // Create users table
  final usersColumns = [
    Column(name: "id", type: "int", primaryKey: true),
    Column(name: "name", type: "string"),
    Column(name: "email", type: "string", unique: true),
    Column(name: "created_at", type: "string"),
  ];
  
  db.createTable("users", usersColumns);
  
  // Create products table
  final productsColumns = [
    Column(name: "id", type: "int", primaryKey: true),
    Column(name: "name", type: "string"),
    Column(name: "price", type: "double"),
    Column(name: "category", type: "string"),
  ];
  
  db.createTable("products", productsColumns);
  
  // Create orders table
  final ordersColumns = [
    Column(name: "id", type: "int", primaryKey: true),
    Column(name: "user_id", type: "int"),
    Column(name: "product_id", type: "int"),
    Column(name: "quantity", type: "int"),
    Column(name: "order_date", type: "string"),
  ];
  
  db.createTable("orders", ordersColumns);
  
  // Test insertions
  db.insertRow("users", {"id": 1, "name": "John Doe", "email": "john@example.com", "created_at": "2023-01-01"});
  db.insertRow("users", {"id": 2, "name": "Jane Smith", "email": "jane@example.com", "created_at": "2023-01-02"});
  
  db.insertRow("products", {"id": 1, "name": "Laptop", "price": 999.99, "category": "Electronics"});
  db.insertRow("products", {"id": 2, "name": "Mouse", "price": 29.99, "category": "Electronics"});
  
  db.insertRow("orders", {"id": 1, "user_id": 1, "product_id": 1, "quantity": 1, "order_date": "2023-01-03"});
  db.insertRow("orders", {"id": 2, "user_id": 2, "product_id": 2, "quantity": 2, "order_date": "2023-01-04"});
  
  // Test selection
  print("\nUsers:");
  var users = db.select("users");
  for (var user in users) {
    print(user);
  }
  
  print("\nProducts:");
  var products = db.select("products");
  for (var product in products) {
    print(product);
  }
  
  print("\nOrders:");
  var orders = db.select("orders");
  for (var order in orders) {
    print(order);
  }
  
  // Test update
  print("\nUpdating user with id=1");
  db.updateRow("users", {"id": 1}, {"name": "John Updated"});
  
  print("\nUsers after update:");
  users = db.select("users");
  for (var user in users) {
    print(user);
  }
  
  // Test selection with filters
  print("\nUser with id=1:");
  var filteredUsers = db.select("users", {"id": 1});
  for (var user in filteredUsers) {
    print(user);
  }
  
  print("\n=== Database Engine Tests Completed ===\n");
}