abstract final class AppConfig {
  // Networking (consumed from Phase 09 onward — no network code before)

  /// Base URL for the REST API.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.invalid',
  );

  /// Connection establishment timeout.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Response read timeout.
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Pagination

  /// Default page size for paginated lists (orders, customers, etc.).
  static const int defaultPageSize = 20;

  // Invoicing / tax

  static const double defaultVatRate = 0.13;

  // Order numbering

  /// First order number issued when the shop has no orders yet, so the first order is `#TS-1001`.
  static const int orderNoStart = 1001;

  /// Human-facing order-number prefix (`#TS-1042`), per the design.
  static const String orderNoPrefix = '#TS-';

  // Feature flags

  /// Master switch for barcode scanning (real implementation lands Phase 01+).
  static const bool barcodeScanningEnabled = true;
}
