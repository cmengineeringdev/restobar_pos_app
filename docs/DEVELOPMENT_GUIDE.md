# Development Guide - Restobar POS

## Quick Start Guide for Adding New Features

### Example: Adding Category Management

Follow these steps to add a complete CRUD feature following Clean Architecture:

#### 1. Domain Layer

**Create Entity** (`lib/domain/entities/category.dart`)
```dart
class Category {
  final int? id;
  final String name;
  final String? description;
  // ... entity implementation
}
```

**Create Repository Interface** (`lib/domain/repositories/category_repository.dart`)
```dart
abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);
  Future<int> insertCategory(Category category);
  // ... other methods
}
```

**Create Use Cases** (`lib/domain/usecases/get_all_categories.dart`)
```dart
class GetAllCategories {
  final CategoryRepository repository;
  
  GetAllCategories({required this.repository});
  
  Future<List<Category>> call() async {
    return await repository.getAllCategories();
  }
}
```

#### 2. Data Layer

**Create Model** (`lib/data/models/category_model.dart`)
```dart
class CategoryModel extends Category {
  CategoryModel({...});
  
  factory CategoryModel.fromMap(Map<String, dynamic> map) {...}
  Map<String, dynamic> toMap() {...}
  factory CategoryModel.fromEntity(Category category) {...}
  Category toEntity() {...}
}
```

**Create Data Source** (`lib/data/datasources/local/category_local_datasource.dart`)
```dart
abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  // ... other methods
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseService databaseService;
  // ... implementation
}
```

**Implement Repository** (`lib/data/repositories/category_repository_impl.dart`)
```dart
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;
  
  CategoryRepositoryImpl({required this.localDataSource});
  
  @override
  Future<List<Category>> getAllCategories() async {
    final models = await localDataSource.getAllCategories();
    return models.map((model) => model.toEntity()).toList();
  }
}
```

#### 3. Register Dependencies

Update `lib/core/injection/injection_container.dart`:
```dart
class InjectionContainer {
  // ... existing code
  
  late CategoryLocalDataSource categoryLocalDataSource;
  late CategoryRepository categoryRepository;
  late GetAllCategories getAllCategories;
  
  Future<void> init() async {
    // ... existing code
    
    // Category dependencies
    categoryLocalDataSource = CategoryLocalDataSourceImpl(
      databaseService: databaseService,
    );
    
    categoryRepository = CategoryRepositoryImpl(
      localDataSource: categoryLocalDataSource,
    );
    
    getAllCategories = GetAllCategories(repository: categoryRepository);
  }
}
```

#### 4. Create UI

**Create Page** (`lib/presentation/pages/categories/categories_page.dart`)
```dart
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final InjectionContainer _container = InjectionContainer();
  late final GetAllCategories _getAllCategories;
  
  List<Category> _categories = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _getAllCategories = _container.getAllCategories;
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _getAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  title: Text(category.name),
                  subtitle: Text(category.description ?? ''),
                );
              },
            ),
    );
  }
}
```

## Code Style Guidelines

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase` with `static const`
- **Private members**: Prefix with `_`

### Example:
```dart
// Good
class ProductRepository { }
final productList = [];
const defaultTimeout = 30;

// Bad
class product_repository { }
final ProductList = [];
const DEFAULT_TIMEOUT = 30;
```

### Import Order

1. Dart SDK imports
2. Flutter imports
3. Package imports
4. Project imports (relative)

```dart
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

import '../../domain/entities/product.dart';
import '../models/product_model.dart';
```

## Testing

### Unit Tests Example

```dart
// test/domain/usecases/get_all_products_test.dart
void main() {
  late GetAllProducts useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetAllProducts(repository: mockRepository);
  });

  test('should get all products from repository', () async {
    // Arrange
    final expectedProducts = [
      Product(id: 1, name: 'Test', price: 10.0),
    ];
    when(mockRepository.getAllProducts())
        .thenAnswer((_) async => expectedProducts);

    // Act
    final result = await useCase();

    // Assert
    expect(result, expectedProducts);
    verify(mockRepository.getAllProducts());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

## Common Patterns

### Error Handling

```dart
try {
  final result = await useCase();
  return Right(result);
} catch (e) {
  if (e is DatabaseException) {
    return Left(DatabaseFailure());
  }
  return Left(UnexpectedFailure());
}
```

### Loading States

```dart
class _MyPageState extends State<MyPage> {
  bool _isLoading = false;
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load data
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

## Database Migrations

When updating database schema, increment version in `database_service.dart`:

```dart
Future<Database> _initDatabase() async {
  return await openDatabase(
    path,
    version: 2, // Increment version
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
}

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE products ADD COLUMN image_url TEXT');
  }
}
```

## Performance Tips

1. **Use const constructors** where possible
2. **Avoid rebuilding widgets** unnecessarily
3. **Use ListView.builder** for long lists
4. **Dispose controllers** in dispose() method
5. **Use async/await** properly

## Useful Commands

```bash
# Get dependencies
flutter pub get

# Run app on Windows
flutter run -d windows

# Build release
flutter build windows --release

# Run tests
flutter test

# Format code
dart format lib/

# Analyze code
flutter analyze

# Generate coverage
flutter test --coverage
```

## Project Checklist for New Features

- [ ] Entity created in domain layer
- [ ] Repository interface defined
- [ ] Use cases implemented
- [ ] Model extends entity
- [ ] Data source implemented
- [ ] Repository implementation complete
- [ ] Dependencies registered in injection container
- [ ] UI page/widget created
- [ ] Error handling implemented
- [ ] Loading states handled
- [ ] Unit tests written
- [ ] Widget tests written
- [ ] Code formatted and analyzed
- [ ] Documentation updated

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SQLite Documentation](https://www.sqlite.org/docs.html)

