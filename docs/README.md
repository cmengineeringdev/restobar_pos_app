# Documentation - Restobar POS App

Welcome to the Restobar POS App documentation. This folder contains comprehensive guides and references to help you understand, develop, and extend the application.

## Documentation Index

### 📐 [Architecture Guide](README_ARCHITECTURE.md)
Complete explanation of the Clean Architecture implementation, project structure, layers, dependencies, and architectural decisions.

**Topics covered:**
- Clean Architecture principles
- Layer responsibilities (Domain, Data, Presentation, Core)
- Project directory structure
- Database schema and tables
- Technology stack
- Features roadmap

**Best for:** Understanding the overall architecture and design patterns

---

### 🛠️ [Development Guide](DEVELOPMENT_GUIDE.md)
Step-by-step instructions for adding new features, following coding standards, and best practices.

**Topics covered:**
- Adding new features (complete example)
- Code style guidelines
- Naming conventions
- Testing patterns
- Database migrations
- Performance tips
- Development checklist

**Best for:** Developers adding new functionality

---

### 📁 [Project Structure](PROJECT_STRUCTURE.md)
Visual representation of the project organization, file structure, and data flow diagrams.

**Topics covered:**
- Complete directory tree
- Layer dependencies diagram
- Data flow visualization
- File naming conventions
- Design principles (SOLID)
- Database schema
- Implementation status

**Best for:** Quick reference to find files and understand organization

---

### 💻 [Usage Examples](USAGE_EXAMPLES.md)
Practical code examples and common patterns for working with the application.

**Topics covered:**
- Running the application
- Database operations
- CRUD operations (Create, Read, Update, Delete)
- Using utilities (formatters, constants)
- Creating custom pages
- Navigation patterns
- Form validation
- Error handling
- Testing examples
- Troubleshooting

**Best for:** Copy-paste code snippets and learning by example

---

## Quick Links

### For New Developers
1. Start with [Architecture Guide](README_ARCHITECTURE.md) to understand the big picture
2. Read [Project Structure](PROJECT_STRUCTURE.md) to know where everything is
3. Check [Usage Examples](USAGE_EXAMPLES.md) to see code in action
4. Follow [Development Guide](DEVELOPMENT_GUIDE.md) when adding features

### For Experienced Developers
1. [Development Guide](DEVELOPMENT_GUIDE.md) - Add features following the checklist
2. [Usage Examples](USAGE_EXAMPLES.md) - Quick code reference
3. [Project Structure](PROJECT_STRUCTURE.md) - Find specific files

### For Code Review
1. [Development Guide](DEVELOPMENT_GUIDE.md) - Check coding standards
2. [Architecture Guide](README_ARCHITECTURE.md) - Verify architectural compliance

---

## Common Tasks

### Running the App
```bash
flutter run -d windows
```
See: [Usage Examples - Running the Application](USAGE_EXAMPLES.md#running-the-application)

### Adding a New Feature
Follow the complete guide in [Development Guide - Adding New Features](DEVELOPMENT_GUIDE.md#example-adding-category-management)

### Understanding Data Flow
See diagrams in [Project Structure - Data Flow](PROJECT_STRUCTURE.md#data-flow)

### Finding a Specific File
Refer to [Project Structure - Visual Directory Tree](PROJECT_STRUCTURE.md#visual-directory-tree)

### Writing Tests
Examples in [Usage Examples - Testing Examples](USAGE_EXAMPLES.md#testing-examples)

---

## Architecture Overview

```
┌─────────────────────────────────┐
│     Presentation Layer          │
│  (UI, Pages, State Management)  │
└───────────────┬─────────────────┘
                │
┌───────────────▼─────────────────┐
│      Domain Layer               │
│  (Entities, Use Cases, Repos)   │
└───────────────┬─────────────────┘
                │
┌───────────────▼─────────────────┐
│       Data Layer                │
│  (Models, Data Sources, Impls)  │
└───────────────┬─────────────────┘
                │
┌───────────────▼─────────────────┐
│    Core & External Services     │
│  (Database, Utils, Constants)   │
└─────────────────────────────────┘
```

## Key Technologies

- **Flutter 3.5.4+** - UI Framework
- **Dart** - Programming Language
- **SQLite** - Local Database
- **Clean Architecture** - Design Pattern
- **Windows** - Primary Platform

---

## Need Help?

1. **Understanding Architecture?** → [Architecture Guide](README_ARCHITECTURE.md)
2. **Adding Features?** → [Development Guide](DEVELOPMENT_GUIDE.md)
3. **Looking for Files?** → [Project Structure](PROJECT_STRUCTURE.md)
4. **Need Code Examples?** → [Usage Examples](USAGE_EXAMPLES.md)

---

**Last Updated:** October 2025  
**Version:** 1.0.0

