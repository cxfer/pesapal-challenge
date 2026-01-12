/// Demo table definitions for the mini-RDBMS
/// 
/// Tables planned:
/// 1. users - stores user information
/// 2. products - stores product information  
/// 3. orders - stores order information linking to users

/*
Sample table structures:

users table:
- id: int, primary key
- name: string
- email: string
- created_at: string (timestamp)

products table:
- id: int, primary key
- name: string
- price: double
- category: string

orders table:
- id: int, primary key
- user_id: int (foreign key to users.id)
- product_id: int (foreign key to products.id)
- quantity: int
- order_date: string (timestamp)
*/