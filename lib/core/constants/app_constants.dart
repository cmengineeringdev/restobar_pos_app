class AppConstants {
  // Database
  static const String databaseName = 'restobar_pos.db';
  static const int databaseVersion = 1;

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusCancelled = 'cancelled';

  // Table Status
  static const String tableStatusAvailable = 'available';
  static const String tableStatusOccupied = 'occupied';
  static const String tableStatusReserved = 'reserved';

  // Currency
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';

  // Pagination
  static const int defaultPageSize = 20;

  // App Info
  static const String appName = 'Restobar POS';
  static const String appVersion = '1.0.0';
}

