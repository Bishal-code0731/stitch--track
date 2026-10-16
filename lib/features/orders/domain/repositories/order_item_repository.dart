import '../entities/order_entity.dart';

abstract interface class OrderItemRepository {
  /// Resolves a scanned Code128 value to its item, or null if unknown.
  Future<OrderItemEntity?> getByBarcode(String barcode);

  /// A single item by id, or null.
  Future<OrderItemEntity?> getById(String id);

  /// Every line item on an order.
  Future<List<OrderItemEntity>> getByOrder(String orderId);
}
