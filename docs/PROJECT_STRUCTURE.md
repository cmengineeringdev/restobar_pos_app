# Project Structure - Restobar POS

## Visual Directory Tree

```
restobar_pos_app/
│
├── lib/
│   │
│   ├── core/                           # Core functionality
│   │   ├── constants/
│   │   │   └── app_constants.dart      # Application-wide constants
│   │   ├── database/
│   │   │   └── database_service.dart   # SQLite database service
│   │   ├── injection/
│   │   │   └── injection_container.dart # Dependency injection
│   │   └── utils/
│   │       ├── currency_formatter.dart # Currency formatting utilities
│   │       └── date_formatter.dart     # Date formatting utilities
│   │
│   ├── data/                           # Data layer
│   │   ├── datasources/
│   │   │   └── local/
│   │   │       └── product_local_datasource.dart # Local data operations
│   │   ├── models/
│   │   │   └── product_model.dart      # Data transfer objects
│   │   └── repositories/
│   │       └── product_repository_impl.dart # Repository implementations
│   │
│   ├── domain/                         # Business logic layer
│   │   ├── entities/
│   │   │   ├── category.dart           # Category entity
│   │   │   ├── order.dart              # Order entity
│   │   │   └── product.dart            # Product entity
│   │   ├── repositories/
│   │   │   └── product_repository.dart # Repository contracts
│   │   └── usecases/
│   │       ├── get_all_products.dart   # Business use case
│   │       └── search_products.dart    # Business use case
│   │
│   ├── presentation/                   # UI layer
│   │   ├── pages/
│   │   │   └── home/
│   │   │       └── home_page.dart      # Home screen
│   │   └── widgets/                    # Reusable widgets (empty for now)
│   │
│   └── main.dart                       # Application entry point
│
├── test/                               # Unit & widget tests
│   └── widget_test.dart
│
├── android/                            # Android platform code
├── ios/                                # iOS platform code
├── linux/                              # Linux platform code
├── macos/                              # macOS platform code
├── windows/                            # Windows platform code
├── web/                                # Web platform code
│
├── pubspec.yaml                        # Dependencies
├── analysis_options.yaml               # Linter rules
├── README.md                           # Main README
├── README_ARCHITECTURE.md              # Architecture documentation
├── DEVELOPMENT_GUIDE.md                # Development guidelines
└── PROJECT_STRUCTURE.md                # This file
```

## Layer Dependencies

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                  │
│  (UI, Pages, Widgets, State Management)     │
└─────────────────┬───────────────────────────┘
                  │ depends on
                  ↓
┌─────────────────────────────────────────────┐
│          Domain Layer                       │
│  (Entities, Repository Interfaces,          │
│   Use Cases, Business Logic)                │
└─────────────────┬───────────────────────────┘
                  ↑ implements
                  │
┌─────────────────────────────────────────────┐
│          Data Layer                         │
│  (Repository Implementations, Data Sources, │
│   Models, API/Database Access)              │
└─────────────────────────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────┐
│      External Dependencies                  │
│  (SQLite, APIs, File System, etc.)          │
└─────────────────────────────────────────────┘
```

## Data Flow

### Reading Data (e.g., Get All Products)

```
User Interaction (UI)
       ↓
[HomePage] - Presentation Layer
       ↓
[GetAllProducts] - Use Case (Domain)
       ↓
[ProductRepository] - Interface (Domain)
       ↓
[ProductRepositoryImpl] - Implementation (Data)
       ↓
[ProductLocalDataSource] - Data Source (Data)
       ↓
[DatabaseService] - SQLite (Core)
       ↓
[SQLite Database File]
       ↓
Return [ProductModel] - Data Layer
       ↓
Convert to [Product] Entity - Domain Layer
       ↓
Display in UI - Presentation Layer
```

### Writing Data (e.g., Insert Product)

```
User Input (UI)
       ↓
[HomePage/Form] - Presentation Layer
       ↓
Create [Product] Entity - Domain
       ↓
[ProductRepository.insertProduct()] - Domain
       ↓
[ProductRepositoryImpl] - Data Layer
       ↓
Convert to [ProductModel] - Data Layer
       ↓
[ProductLocalDataSource.insertProduct()] - Data
       ↓
[DatabaseService] - Core
       ↓
INSERT INTO products ... - SQLite
       ↓
Return success/error
       ↓
Update UI
```

## File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `ProductRepository` |
| Files | snake_case | `product_repository.dart` |
| Variables | camelCase | `productList` |
| Constants | camelCase | `defaultTimeout` |
| Private | _prefix | `_privateMethod` |

## Key Design Principles

### 1. Separation of Concerns
Each layer has a single, well-defined responsibility:
- **Presentation**: Display data and handle user input
- **Domain**: Business rules and logic
- **Data**: Data access and persistence

### 2. Dependency Rule
Dependencies only point inward:
- Presentation depends on Domain
- Data depends on Domain
- Domain depends on nothing (pure Dart)

### 3. Abstractions
- Domain defines interfaces (contracts)
- Data/Presentation implement them
- Allows easy testing and swapping implementations

### 4. Single Responsibility
Each class/file has one reason to change:
- `ProductEntity`: Changes when business rules change
- `ProductModel`: Changes when database schema changes
- `ProductPage`: Changes when UI requirements change

## Database Schema

```sql
-- Products Table
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  price REAL NOT NULL,
  category_id INTEGER,
  stock INTEGER DEFAULT 0,
  active INTEGER DEFAULT 1,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories (id)
);

-- Categories Table
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  active INTEGER DEFAULT 1,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Tables
CREATE TABLE tables (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  number INTEGER NOT NULL UNIQUE,
  capacity INTEGER NOT NULL,
  status TEXT DEFAULT 'available',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Orders
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_id INTEGER,
  total REAL DEFAULT 0,
  status TEXT DEFAULT 'pending',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  completed_at TEXT,
  FOREIGN KEY (table_id) REFERENCES tables (id)
);

-- Order Items
CREATE TABLE order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  subtotal REAL NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders (id),
  FOREIGN KEY (product_id) REFERENCES products (id)
);
```

## Current Implementation Status

### ✅ Completed
- SQLite database integration
- Clean Architecture structure
- Product entity, repository, and use cases
- Product data source and model
- Home page with product list
- Search functionality
- Dependency injection
- Core utilities (formatters, constants)
- Additional entities (Category, Order)

### 🚧 To Be Implemented
- Category CRUD operations
- Table management
- Order creation and management
- Order items handling
- Sales reports
- User authentication
- Settings page
- State management (BLoC/Riverpod)
- Integration tests
- More comprehensive unit tests

## Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Dart |
| Framework | Flutter |
| Database | SQLite (sqflite_common_ffi) |
| Architecture | Clean Architecture |
| Dependency Injection | Manual (InjectionContainer) |
| State Management | setState (to be upgraded) |
| Platform | Windows (primary), cross-platform capable |

## Next Steps for Developers

1. **Understand the Structure**: Read this document and architecture README
2. **Explore the Code**: Start from `main.dart` → Domain → Data → Presentation
3. **Run the App**: `flutter run -d windows`
4. **Add a Feature**: Follow DEVELOPMENT_GUIDE.md to add categories
5. **Write Tests**: Create unit tests for new features
6. **Refactor State Management**: Consider adding BLoC or Riverpod
7. **Add More Features**: Implement orders, tables, reports

## Contact & Support

For questions or issues:
1. Check DEVELOPMENT_GUIDE.md
2. Review Clean Architecture principles
3. Consult Flutter documentation
4. Debug with `flutter analyze` and `flutter doctor`

