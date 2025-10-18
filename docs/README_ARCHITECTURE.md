# Restobar POS App - Clean Architecture

## Project Structure

This project follows Clean Architecture principles to ensure separation of concerns, testability, and maintainability.

```
lib/
├── core/                       # Core utilities and services
│   ├── database/              # Database configuration
│   │   └── database_service.dart
│   └── injection/             # Dependency injection
│       └── injection_container.dart
│
├── data/                      # Data layer
│   ├── datasources/          # Data sources
│   │   └── local/
│   │       └── product_local_datasource.dart
│   ├── models/               # Data models
│   │   └── product_model.dart
│   └── repositories/         # Repository implementations
│       └── product_repository_impl.dart
│
├── domain/                    # Domain layer (Business Logic)
│   ├── entities/             # Business entities
│   │   └── product.dart
│   ├── repositories/         # Repository interfaces
│   │   └── product_repository.dart
│   └── usecases/             # Use cases
│       ├── get_all_products.dart
│       └── search_products.dart
│
├── presentation/              # Presentation layer (UI)
│   ├── pages/
│   │   └── home/
│   │       └── home_page.dart
│   └── widgets/              # Reusable widgets
│
└── main.dart                 # Application entry point
```

## Architecture Layers

### 1. Domain Layer (Business Logic)
- **Entities**: Core business objects (pure Dart classes)
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Application-specific business rules

### 2. Data Layer
- **Data Sources**: Handle data from different sources (local DB, remote API)
- **Models**: Data transfer objects that extend entities
- **Repository Implementations**: Concrete implementations of repository interfaces

### 3. Presentation Layer
- **Pages**: Full screen widgets
- **Widgets**: Reusable UI components
- **State Management**: (To be implemented - BLoC, Provider, Riverpod, etc.)

### 4. Core Layer
- **Database**: SQLite database configuration and initialization
- **Dependency Injection**: Manual dependency injection setup
- **Constants**: App-wide constants
- **Utils**: Utility functions

## Database

The app uses SQLite via `sqflite_common_ffi` which supports:
- ✅ Windows
- ✅ Linux
- ✅ macOS
- ✅ iOS
- ✅ Android

### Database Tables

1. **categories**
   - id, name, description, active, created_at

2. **products**
   - id, name, description, price, category_id, stock, active, created_at

3. **tables**
   - id, number, capacity, status, created_at

4. **orders**
   - id, table_id, total, status, created_at, completed_at

5. **order_items**
   - id, order_id, product_id, quantity, unit_price, subtotal

## Getting Started

### Prerequisites
- Flutter SDK 3.5.4 or higher
- Windows 10/11 (primary target)

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d windows
```

## Dependencies

- **sqflite_common_ffi**: SQLite database for desktop platforms
- **path_provider**: Get application directories
- **path**: Path manipulation utilities

## Features

- ✅ SQLite database integration
- ✅ Clean Architecture implementation
- ✅ Product management (CRUD operations)
- ✅ Search functionality
- 🚧 Category management
- 🚧 Table management
- 🚧 Order management
- 🚧 Sales reports

## Development

### Adding New Features

1. **Define Entity** in `domain/entities/`
2. **Create Repository Interface** in `domain/repositories/`
3. **Implement Use Cases** in `domain/usecases/`
4. **Create Data Model** in `data/models/`
5. **Implement Data Source** in `data/datasources/`
6. **Implement Repository** in `data/repositories/`
7. **Register Dependencies** in `core/injection/injection_container.dart`
8. **Create UI** in `presentation/pages/` or `presentation/widgets/`

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Best Practices

1. **Separation of Concerns**: Each layer has its own responsibility
2. **Dependency Rule**: Dependencies point inward (Presentation → Domain ← Data)
3. **Testability**: Business logic is independent of frameworks
4. **Scalability**: Easy to add new features without affecting existing code
5. **English Naming**: All file names and variables use English

## License

This project is private and proprietary.

