import 'lib/rdbms/db_engine.dart';
import 'lib/rdbms/column.dart';

void main() {
  print("=== Testing JOIN Operations ===");
  
  final db = DbEngine();
  
  // Create users table
  final usersColumns = [
    Column(name: "id", type: "int", primaryKey: true),
    Column(name: "name", type: "string"),
    Column(name: "email", type: "string", unique: true),
  ];
  
  db.createTable("users", usersColumns);
  
  // Create products table
  final productsColumns = [
    Column(name: "id", type: "int", primaryKey: true),
    Column(name: "name", type: "string"),
    Column(name: "price", type: "double"),
  ];
  
  db.createTable("products", productsColumns);
  
  // Create orders table
  final ordersColumns = [
    Column(name: "id", type: "int", primaryKey: true),
    Column(name: "user_id", type: "int"),
    Column(name: "product_id", type: "int"),
    Column(name: "quantity", type: "int"),
  ];
  
  db.createTable("orders", ordersColumns);
  
  // Insert test data
  db.insertRow("users", {"id": 1, "name": "John Doe", "email": "john@example.com"});
  db.insertRow("users", {"id": 2, "name": "Jane Smith", "email": "jane@example.com"});
  
  db.insertRow("products", {"id": 1, "name": "Laptop", "price": 999.99});
  db.insertRow("products", {"id": 2, "name": "Mouse", "price": 29.99});
  
  db.insertRow("orders", {"id": 1, "user_id": 1, "product_id": 1, "quantity": 1});
  db.insertRow("orders", {"id": 2, "user_id": 2, "product_id": 2, "quantity": 3});
  
  // Test JOIN: users join orders on user_id
  print("\nJOIN: users JOIN orders ON users.id = orders.user_id");
  var joinResult = db.joinTables("users", "orders", "id", "user_id");
  for (var row in joinResult) {
    print(row);
  }
  
  // Test another JOIN: orders join products on product_id
  print("\nJOIN: orders JOIN products ON orders.product_id = products.id");
  joinResult = db.joinTables("orders", "products", "product_id", "id");
  for (var row in joinResult) {
    print(row);
  }
  
  // Test a three-way scenario (manually combining results)
  print("\nSimulated three-way JOIN: users JOIN orders JOIN products");
  var userOrderJoin = db.joinTables("users", "orders", "id", "user_id");
  for (var userOrder in userOrderJoin) {
    var productId = userOrder["product_id"];
    var productJoin = db.select("products", {"id": productId});
    for (var product in productJoin) {
      // Combine user+order with product
      var combined = Map<String, dynamic>.from(userOrder);
      combined.addAll({"product_name": product["name"], "product_price": product["price"]});
      print(combined);
    }
  }
  
  print("\n=== JOIN Tests Completed ===\n");
}