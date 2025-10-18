class DateFormatter {
  /// Format date to readable string (e.g., "Jan 15, 2024")
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format date and time (e.g., "Jan 15, 2024 10:30 AM")
  static String formatDateTime(DateTime? date) {
    if (date == null) return '-';
    
    final dateStr = formatDate(date);
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    
    return '$dateStr $hour:$minute $period';
  }

  /// Format time only (e.g., "10:30 AM")
  static String formatTime(DateTime? date) {
    if (date == null) return '-';
    
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    
    return '$hour:$minute $period';
  }
}

