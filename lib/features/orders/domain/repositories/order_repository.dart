import '../../../../core/database/enums.dart';
import '../entities/order_entity.dart';
import '../entities/order_requests.dart';

/// The order lifecycle's data gateway.
abstract interface class OrderRepository {
  Future<List<OrderEntity>> getOrders({String? branchId, OrderFilter filter});

  /// A single order with its line items, or null if not found.
  Future<OrderWithItems?> getOrderById(String id);

  Future<OrderWithItems> createOrder(NewOrderRequest request);

  /// Edits an existing order's discount/dates/notes, recomputing VAT/total and balance.
  Future<OrderWithItems> updateOrder(UpdateOrderRequest request);

  Future<OrderWithItems> cancelOrder({
    required String orderId,
    required CancelledReason reason,
    required String cancelledBy,
    String? note,
    bool refundAdvance = false,
  });

  Future<OrderWithItems> updateItemStage({
    required String orderItemId,
    required OrderStatus toStage,
    required String changedBy,
    String? note,
    bool whatsappTriggered = false,
  });

  Future<LastMeasurements?> lastMeasurementsFor({
    required String customerId,
    required String templateId,
  });
}

class LastMeasurements {
  const LastMeasurements({required this.values, required this.orderDate});
  final Map<String, double> values;
  final DateTime orderDate;
}
