# Usage Examples - Restobar POS

## Running the Application

### Development Mode (Windows)
```bash
flutter run -d windows
```

### Release Build
```bash
flutter build windows --release
```

The executable will be located at:
```
build/windows/runner/Release/restobar_pos_app.exe
```

## Code Examples

### 1. Using the Database Service

```dart
import 'package:restobar_pos_app/core/database/database_service.dart';

// Get database instance
final dbService = DatabaseService();
final db = await dbService.database;

// Execute raw query
final results = await db.query('products', limit: 10);

// Reset database (development only)
await dbService.resetDatabase();
```

### 2. Working with Products

#### Get All Products
```dart
import 'package:restobar_pos_app/core/injection/injection_container.dart';

final container = InjectionContainer();
final getAllProducts = container.getAllProducts;

try {
  final products = await getAllProducts();
  for (var product in products) {
    print('${product.name}: \$${product.price}');
  }
} catch (e) {
  print('Error: $e');
}
```

#### Search Products
```dart
final searchProducts = container.searchProducts;

final results = await searchProducts('coffee');
print('Found ${results.length} products');
```

#### Insert New Product
```dart
import 'package:restobar_pos_app/domain/entities/product.dart';

final container = InjectionContainer();
final repository = container.productRepository;

final newProduct = Product(
  name: 'Cappuccino',
  description: 'Italian coffee with milk foam',
  price: 7.50,
  categoryId: 1,
  stock: 50,
);

final id = await repository.insertProduct(newProduct);
print('Product created with ID: $id');
```

#### Update Product
```dart
final product = await repository.getProductById(1);

if (product != null) {
  final updated = product.copyWith(
    price: 8.00,
    stock: product.stock - 5,
  );
  
  await repository.updateProduct(updated);
  print('Product updated successfully');
}
```

#### Delete Product (Soft Delete)
```dart
await repository.deleteProduct(1);
print('Product deactivated');
```

#### Update Stock
```dart
await repository.updateProductStock(1, 100);
print('Stock updated');
```

### 3. Direct Database Operations

#### Query with Conditions
```dart
final db = await DatabaseService().database;

final expensiveProducts = await db.query(
  'products',
  where: 'price > ? AND active = ?',
  whereArgs: [20.0, 1],
  orderBy: 'price DESC',
);
```

#### Join Tables
```dart
final productsWithCategories = await db.rawQuery('''
  SELECT p.*, c.name as category_name
  FROM products p
  LEFT JOIN categories c ON p.category_id = c.id
  WHERE p.active = 1
''');
```

#### Transaction Example
```dart
await db.transaction((txn) async {
  // Insert order
  final orderId = await txn.insert('orders', {
    'table_id': 1,
    'status': 'pending',
    'total': 0.0,
  });
  
  // Insert order items
  await txn.insert('order_items', {
    'order_id': orderId,
    'product_id': 1,
    'quantity': 2,
    'unit_price': 5.50,
    'subtotal': 11.00,
  });
  
  // Update order total
  await txn.update('orders',
    {'total': 11.00},
    where: 'id = ?',
    whereArgs: [orderId],
  );
});
```

### 4. Using Utilities

#### Format Currency
```dart
import 'package:restobar_pos_app/core/utils/currency_formatter.dart';

final price = 25.5;
final formatted = CurrencyFormatter.format(price);
print(formatted); // Output: $25.50

final parsed = CurrencyFormatter.parse('\$100.50');
print(parsed); // Output: 100.5
```

#### Format Dates
```dart
import 'package:restobar_pos_app/core/utils/date_formatter.dart';

final now = DateTime.now();

print(DateFormatter.formatDate(now));
// Output: Oct 17, 2025

print(DateFormatter.formatDateTime(now));
// Output: Oct 17, 2025 2:30 PM

print(DateFormatter.formatTime(now));
// Output: 2:30 PM
```

### 5. Creating a Custom Page

```dart
import 'package:flutter/material.dart';
import 'package:restobar_pos_app/core/injection/injection_container.dart';
import 'package:restobar_pos_app/domain/entities/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _container = InjectionContainer();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final products = await _container.getAllProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('\$${product.price}'),
                  trailing: Text('Stock: ${product.stock}'),
                );
              },
            ),
    );
  }
}
```

### 6. Adding Navigation

Update `main.dart`:
```dart
import 'package:flutter/material.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/products/products_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restobar POS',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/products': (context) => const ProductsPage(),
      },
    );
  }
}
```

Navigate between pages:
```dart
// Navigate to products page
Navigator.pushNamed(context, '/products');

// Navigate back
Navigator.pop(context);

// Navigate with data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailsPage(productId: 1),
  ),
);
```

### 7. Error Handling Pattern

```dart
Future<void> _performDatabaseOperation() async {
  try {
    setState(() => _isLoading = true);
    
    final result = await someOperation();
    
    setState(() {
      _data = result;
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Operation successful'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### 8. Form Validation Example

```dart
class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );

      try {
        final container = InjectionContainer();
        await container.productRepository.insertProduct(product);
        
        if (mounted) {
          Navigator.pop(context, true); // Return success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Product Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _stockController,
            decoration: const InputDecoration(labelText: 'Stock'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter stock quantity';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Save Product'),
          ),
        ],
      ),
    );
  }
}
```

## Testing Examples

### Unit Test
```dart
// test/domain/usecases/get_all_products_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:restobar_pos_app/domain/entities/product.dart';
import 'package:restobar_pos_app/domain/usecases/get_all_products.dart';

void main() {
  test('GetAllProducts should return list of products', () async {
    // Setup
    final container = InjectionContainer();
    await container.init();
    final useCase = container.getAllProducts;

    // Execute
    final products = await useCase();

    // Verify
    expect(products, isA<List<Product>>());
    expect(products.length, greaterThan(0));
  });
}
```

### Widget Test
```dart
// test/presentation/pages/home_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restobar_pos_app/presentation/pages/home/home_page.dart';

void main() {
  testWidgets('HomePage displays products', (WidgetTester tester) async {
    // Build widget
    await tester.pumpWidget(
      const MaterialApp(home: HomePage()),
    );

    // Wait for data to load
    await tester.pumpAndSettle();

    // Verify
    expect(find.text('Restobar POS - Products'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });
}
```

## Troubleshooting

### Database File Location
```dart
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

Future<void> printDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'restobar_pos.db');
  print('Database location: $path');
}
```

### View Database Content (Debug)
```dart
Future<void> debugDatabase() async {
  final db = await DatabaseService().database;
  
  // View all tables
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table'"
  );
  print('Tables: $tables');
  
  // Count products
  final count = await db.rawQuery('SELECT COUNT(*) FROM products');
  print('Product count: $count');
  
  // View all products
  final products = await db.query('products');
  print('Products: $products');
}
```

## Performance Optimization

### Use Batch Operations
```dart
final db = await DatabaseService().database;
final batch = db.batch();

for (var product in products) {
  batch.insert('products', product.toMap());
}

await batch.commit(noResult: true);
```

### Indexed Queries
```dart
// Create index for faster searches
await db.execute(
  'CREATE INDEX idx_product_name ON products(name)'
);
```

## Common Patterns

### Refresh List After Changes
```dart
Future<void> _deleteProduct(int id) async {
  await repository.deleteProduct(id);
  await _loadProducts(); // Refresh list
}
```

### Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: _loadProducts,
  child: ListView.builder(...),
)
```

