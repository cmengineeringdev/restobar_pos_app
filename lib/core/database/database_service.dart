import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize SQLite database
  Future<Database> _initDatabase() async {
    // Get application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'restobar_pos.db');

    // Open/create database
    Database db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3, // Incrementado para agregar tabla point_of_sale
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );

    return db;
  }

  /// Create initial database tables
  Future<void> _onCreate(Database db, int version) async {
    // Products table - adapted to API structure
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id INTEGER NOT NULL UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        sale_price REAL NOT NULL,
        is_active INTEGER DEFAULT 1,
        product_category_id INTEGER,
        tax_rate_id INTEGER,
        formula_id INTEGER,
        formula_code TEXT,
        formula_name TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Index for better search performance
    await db.execute('''
      CREATE INDEX idx_product_name ON products(name)
    ''');

    await db.execute('''
      CREATE INDEX idx_product_is_active ON products(is_active)
    ''');

    await db.execute('''
      CREATE INDEX idx_product_remote_id ON products(remote_id)
    ''');

    // Point of Sale table (selected location)
    await db.execute('''
      CREATE TABLE selected_point_of_sale (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        number_of_tables INTEGER NOT NULL,
        manager_id INTEGER,
        manager_name TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        selected_at TEXT NOT NULL
      )
    ''');
  }

  /// Handle database version upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration from version 1 to 2: Add remote_id column
    if (oldVersion < 2) {
      // Drop and recreate products table with new schema
      await db.execute('DROP TABLE IF EXISTS products');

      // Recreate with new schema
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          remote_id INTEGER NOT NULL UNIQUE,
          name TEXT NOT NULL,
          description TEXT,
          sale_price REAL NOT NULL,
          is_active INTEGER DEFAULT 1,
          product_category_id INTEGER,
          tax_rate_id INTEGER,
          formula_id INTEGER,
          formula_code TEXT,
          formula_name TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');

      // Recreate indices
      await db.execute('CREATE INDEX idx_product_name ON products(name)');
      await db
          .execute('CREATE INDEX idx_product_is_active ON products(is_active)');
      await db
          .execute('CREATE INDEX idx_product_remote_id ON products(remote_id)');
    }

    // Migration from version 2 to 3: Add point_of_sale table
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS selected_point_of_sale (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          number_of_tables INTEGER NOT NULL,
          manager_id INTEGER,
          manager_name TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          selected_at TEXT NOT NULL
        )
      ''');
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Reset database (useful for development/testing)
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'restobar_pos.db');

    File dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    _database = await _initDatabase();
  }
}
