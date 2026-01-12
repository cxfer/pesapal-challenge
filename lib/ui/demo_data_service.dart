import '../rdbms/db_engine.dart';
import '../rdbms/column.dart';

class DemoDataService {
  static void populateDemoData(DbEngine engine) {
    // Create users table
    final usersColumns = [
      Column(name: "id", type: "int", primaryKey: true),
      Column(name: "name", type: "string"),
      Column(name: "email", type: "string", unique: true),
      Column(name: "age", type: "int"),
    ];
    
    engine.createTable("users", usersColumns);
    
    // Create products table
    final productsColumns = [
      Column(name: "id", type: "int", primaryKey: true),
      Column(name: "name", type: "string"),
      Column(name: "price", type: "double"),
      Column(name: "category", type: "string"),
    ];
    
    engine.createTable("products", productsColumns);
    
    // Create orders table
    final ordersColumns = [
      Column(name: "id", type: "int", primaryKey: true),
      Column(name: "user_id", type: "int"),
      Column(name: "product_id", type: "int"),
      Column(name: "quantity", type: "int"),
      Column(name: "order_date", type: "string"),
    ];
    
    engine.createTable("orders", ordersColumns);
    
    // Insert demo users (3-5 entries)
    engine.insertRow("users", {"id": 1, "name": "Alice Johnson", "email": "alice@example.com", "age": 28});
    engine.insertRow("users", {"id": 2, "name": "Bob Smith", "email": "bob@example.com", "age": 35});
    engine.insertRow("users", {"id": 3, "name": "Charlie Brown", "email": "charlie@example.com", "age": 42});
    engine.insertRow("users", {"id": 4, "name": "Diana Prince", "email": "diana@example.com", "age": 30});
    engine.insertRow("users", {"id": 5, "name": "Ethan Hunt", "email": "ethan@example.com", "age": 38});
    
    // Insert demo products (3-5 entries)
    engine.insertRow("products", {"id": 1, "name": "Laptop", "price": 999.99, "category": "Electronics"});
    engine.insertRow("products", {"id": 2, "name": "Smartphone", "price": 699.99, "category": "Electronics"});
    engine.insertRow("products", {"id": 3, "name": "Headphones", "price": 149.99, "category": "Electronics"});
    engine.insertRow("products", {"id": 4, "name": "Desk Chair", "price": 199.99, "category": "Furniture"});
    engine.insertRow("products", {"id": 5, "name": "Coffee Maker", "price": 89.99, "category": "Appliances"});
    
    // Insert demo orders (3-5 entries)
    engine.insertRow("orders", {"id": 1, "user_id": 1, "product_id": 1, "quantity": 1, "order_date": "2023-01-15"});
    engine.insertRow("orders", {"id": 2, "user_id": 2, "product_id": 3, "quantity": 2, "order_date": "2023-01-16"});
    engine.insertRow("orders", {"id": 3, "user_id": 3, "product_id": 2, "quantity": 1, "order_date": "2023-01-17"});
    engine.insertRow("orders", {"id": 4, "user_id": 4, "product_id": 4, "quantity": 1, "order_date": "2023-01-18"});
    engine.insertRow("orders", {"id": 5, "user_id": 5, "product_id": 5, "quantity": 1, "order_date": "2023-01-19"});
  }
}