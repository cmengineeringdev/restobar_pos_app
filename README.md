# Restobar POS App

A Point of Sale (POS) application for restaurants and bars built with Flutter, following Clean Architecture principles and using SQLite for local data persistence.

## Features

- ✅ Product management with CRUD operations
- ✅ Category organization
- ✅ Real-time product search
- ✅ SQLite database integration
- ✅ Clean Architecture implementation
- ✅ Cross-platform support (Windows primary)
- 🚧 Table management (coming soon)
- 🚧 Order processing (coming soon)
- 🚧 Sales reports (coming soon)

## Technology Stack

- **Framework**: Flutter 3.5.4+
- **Language**: Dart
- **Database**: SQLite (sqflite_common_ffi)
- **Architecture**: Clean Architecture
- **Primary Platform**: Windows
- **Supported Platforms**: Windows, Linux, macOS, iOS, Android

## Quick Start

### Prerequisites

- Flutter SDK 3.5.4 or higher
- Windows 10/11 (for primary development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd restobar_pos_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d windows
```

### Build Release

```bash
flutter build windows --release
```

The executable will be located at: `build/windows/runner/Release/restobar_pos_app.exe`

## Project Structure

```
lib/
├── core/                # Core utilities and services
│   ├── constants/      # Application constants
│   ├── database/       # SQLite configuration
│   ├── injection/      # Dependency injection
│   └── utils/          # Utility functions
├── data/               # Data layer
│   ├── datasources/    # Data sources (local/remote)
│   ├── models/         # Data models
│   └── repositories/   # Repository implementations
├── domain/             # Business logic layer
│   ├── entities/       # Business entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Use cases
└── presentation/       # UI layer
    ├── pages/          # Application screens
    └── widgets/        # Reusable widgets
```

## Documentation

Comprehensive documentation is available in the `docs/` folder:

- **[Architecture Guide](docs/README_ARCHITECTURE.md)** - Detailed explanation of Clean Architecture implementation
- **[Development Guide](docs/DEVELOPMENT_GUIDE.md)** - Step-by-step guide for adding new features
- **[Project Structure](docs/PROJECT_STRUCTURE.md)** - Complete project organization and file structure
- **[Usage Examples](docs/USAGE_EXAMPLES.md)** - Code examples and common patterns

## Database

The application uses SQLite with the following tables:

- **products** - Product information
- **categories** - Product categories
- **tables** - Restaurant tables
- **orders** - Customer orders
- **order_items** - Order line items

Sample data is automatically inserted on first run for testing purposes.

## Development

### Adding New Features

1. Define entity in `domain/entities/`
2. Create repository interface in `domain/repositories/`
3. Implement use cases in `domain/usecases/`
4. Create data model in `data/models/`
5. Implement data source in `data/datasources/`
6. Implement repository in `data/repositories/`
7. Register dependencies in `core/injection/injection_container.dart`
8. Create UI in `presentation/`

See [Development Guide](docs/DEVELOPMENT_GUIDE.md) for detailed instructions.

### Code Quality

```bash
# Run static analysis
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test
```

## Contributing

1. Follow Clean Architecture principles
2. Use English for all code, comments, and file names
3. Write tests for new features
4. Format code before committing
5. Update documentation as needed

## Architecture

This project follows **Clean Architecture** principles:

- **Separation of Concerns**: Each layer has a single responsibility
- **Dependency Rule**: Dependencies point inward (Presentation → Domain ← Data)
- **Testability**: Business logic is independent of frameworks
- **Maintainability**: Easy to modify and extend

For more details, see [Architecture Guide](docs/README_ARCHITECTURE.md).

## License

This project is private and proprietary.

## Support

For questions or issues:
1. Check the [documentation](docs/)
2. Review [usage examples](docs/USAGE_EXAMPLES.md)
3. Consult the [development guide](docs/DEVELOPMENT_GUIDE.md)

---

**Version**: 1.0.0  
**Last Updated**: October 2025
