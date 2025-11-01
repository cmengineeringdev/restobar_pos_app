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
        version: 13, // Incrementado para agregar cancellation_reason a orders
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
        is_available INTEGER DEFAULT 1,
        product_category_id INTEGER,
        tax_rate_id INTEGER,
        tax_rate REAL,
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

    // Work Shifts table
    await db.execute('''
      CREATE TABLE work_shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id INTEGER UNIQUE,
        open_date TEXT NOT NULL,
        close_date TEXT,
        company_id INTEGER NOT NULL,
        point_of_sale_id INTEGER NOT NULL,
        user_id TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Index for better work shift queries
    await db.execute('''
      CREATE INDEX idx_work_shift_is_active ON work_shifts(is_active)
    ''');

    await db.execute('''
      CREATE INDEX idx_work_shift_point_of_sale ON work_shifts(point_of_sale_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_work_shift_remote_id ON work_shifts(remote_id)
    ''');

    // Tables (mesas) table
    await db.execute('''
      CREATE TABLE tables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT NOT NULL,
        capacity INTEGER NOT NULL DEFAULT 4,
        status TEXT NOT NULL DEFAULT 'available',
        point_of_sale_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_table_point_of_sale ON tables(point_of_sale_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_table_status ON tables(status)
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_id INTEGER NOT NULL,
        work_shift_id INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'open',
        subtotal REAL NOT NULL DEFAULT 0,
        tax REAL NOT NULL DEFAULT 0,
        tip REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL DEFAULT 0,
        notes TEXT,
        cancellation_reason TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        closed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_order_table ON orders(table_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_order_work_shift ON orders(work_shift_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_order_status ON orders(status)
    ''');

    // Order Items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        tax_rate REAL NOT NULL DEFAULT 0,
        tax_amount REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_order_item_order ON order_items(order_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_order_item_product ON order_items(product_id)
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'completed',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_payment_order ON payments(order_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_payment_status ON payments(status)
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

    // Migration from version 3 to 4: Add work_shifts table
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS work_shifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          remote_id INTEGER UNIQUE,
          open_date TEXT NOT NULL,
          close_date TEXT,
          company_id INTEGER NOT NULL,
          point_of_sale_id INTEGER NOT NULL,
          user_id TEXT,
          is_active INTEGER DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_work_shift_is_active ON work_shifts(is_active)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_work_shift_point_of_sale ON work_shifts(point_of_sale_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_work_shift_remote_id ON work_shifts(remote_id)
      ''');
    }

    // Migration from version 4 to 5: Add tables table
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tables (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          number TEXT NOT NULL,
          capacity INTEGER NOT NULL DEFAULT 4,
          status TEXT NOT NULL DEFAULT 'available',
          point_of_sale_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_table_point_of_sale ON tables(point_of_sale_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_table_status ON tables(status)
      ''');
    }

    // Migration from version 5 to 6: Add orders and order_items tables
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          table_id INTEGER NOT NULL,
          work_shift_id INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'open',
          subtotal REAL NOT NULL DEFAULT 0,
          tax REAL NOT NULL DEFAULT 0,
          total REAL NOT NULL DEFAULT 0,
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          closed_at TEXT
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_order_table ON orders(table_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_order_work_shift ON orders(work_shift_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_order_status ON orders(status)
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS order_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 1,
          unit_price REAL NOT NULL,
          subtotal REAL NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_order_item_order ON order_items(order_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_order_item_product ON order_items(product_id)
      ''');
    }

    // Migration from version 6 to 7: Add notes column to orders
    if (oldVersion < 7 && oldVersion >= 6) {
      await db.execute('''
        ALTER TABLE orders ADD COLUMN notes TEXT
      ''');
    }

    // Migration from version 7 to 8: Add payments table
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER NOT NULL,
          payment_method TEXT NOT NULL,
          amount REAL NOT NULL,
          status TEXT NOT NULL DEFAULT 'completed',
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_payment_order ON payments(order_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_payment_status ON payments(status)
      ''');
    }

    // Migration from version 8 to 9: Add is_available column to products
    if (oldVersion < 9) {
      await db.execute('''
        ALTER TABLE products ADD COLUMN is_available INTEGER DEFAULT 1
      ''');
    }

    // Migration from version 9 to 10: Add tip column to orders
    if (oldVersion < 10) {
      await db.execute('''
        ALTER TABLE orders ADD COLUMN tip REAL NOT NULL DEFAULT 0
      ''');
    }

    // Migration from version 10 to 11: Add tax_rate column to products
    if (oldVersion < 11) {
      await db.execute('''
        ALTER TABLE products ADD COLUMN tax_rate REAL
      ''');
    }

    // Migration from version 11 to 12: Add tax_rate and tax_amount columns to order_items
    if (oldVersion < 12) {
      await db.execute('''
        ALTER TABLE order_items ADD COLUMN tax_rate REAL NOT NULL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE order_items ADD COLUMN tax_amount REAL NOT NULL DEFAULT 0
      ''');
    }

    // Migration from version 12 to 13: Add cancellation_reason column to orders
    if (oldVersion < 13) {
      await db.execute('''
        ALTER TABLE orders ADD COLUMN cancellation_reason TEXT
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
