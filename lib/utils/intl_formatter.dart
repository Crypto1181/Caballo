/// Internationalization formatter utilities
class IntlFormatter {
  /// Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format percentage
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(2)}%';
  }

  /// Format date
  static String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Format date time
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

