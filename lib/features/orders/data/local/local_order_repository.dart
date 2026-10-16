import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/measurement_utils.dart';
import '../../domain/entities/order_exceptions.dart';
import '../../domain/entities/order_pricing.dart';
import '../../domain/entities/order_requests.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_mappers.dart';

/// Drift-backed [OrderRepository] — the only implementation before Phase 09.
class LocalOrderRepository implements OrderRepository {
  LocalOrderRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  @override
  Future<List<OrderEntity>> getOrders({
    String? branchId,
    OrderFilter filter = const OrderFilter(),
  }) async {
    final rows = branchId == null
        ? await _db.orderDao.getAll()
        : await _db.orderDao.getByBranch(branchId);

    // Garment-type filtering needs the items; only look them up if asked.
    Set<String>? orderIdsWithGarment;
    if (filter.garmentTemplateId != null) {
      final items = await _db.orderItemDao.getAll();
      orderIdsWithGarment = items
          .where((i) => i.garmentTemplateId == filter.garmentTemplateId)
          .map((i) => i.orderId)
          .toSet();
    }

    final search = filter.search?.trim().toLowerCase();
    final matched = rows.where((o) {
      if (!filter.includeCancelled && o.status == OrderStatus.cancelled) {
        return false;
      }
      if (filter.status != null && o.status != filter.status) return false;
      if (filter.customerId != null && o.customerId != filter.customerId) {
        return false;
      }
      if (orderIdsWithGarment != null && !orderIdsWithGarment.contains(o.id)) {
        return false;
      }
      if (filter.dueFrom != null && o.deliveryDate.isBefore(filter.dueFrom!)) {
        return false;
      }
      if (filter.dueTo != null && o.deliveryDate.isAfter(filter.dueTo!)) {
        return false;
      }
      if (search != null &&
          search.isNotEmpty &&
          !o.orderNo.toLowerCase().contains(search)) {
        return false;
      }
      return true;
    }).toList();

    // Newest first.
    matched.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matched.map((r) => r.toEntity()).toList();
  }

  @override
  Future<OrderWithItems?> getOrderById(String id) async {
    final order = await _db.orderDao.getById(id);
    if (order == null) return null;
    final items = await _db.orderItemDao.getByOrder(id);
    return OrderWithItems(
      order: order.toEntity(),
      items: items.map((i) => i.toEntity()).toList(),
    );
  }

  @override
  Future<OrderWithItems> createOrder(NewOrderRequest request) async {
    if (request.items.isEmpty) throw const EmptyOrderException();

    final vatRate = request.vatRate ?? AppConfig.defaultVatRate;
    final subtotal = orderSubtotal(
      request.items.map((i) => (price: i.price, quantity: i.quantity)),
    );
    final pricing = OrderPricing.compute(
      subtotal: subtotal,
      discount: request.discount,
      vatRate: vatRate,
    );
    final balance = pricing.balanceAfter(request.advanceAmount);

    return _db.transaction(() async {
      final orderNo = await _nextOrderNo();
      final orderNoCore = _digitsOf(orderNo);
      final orderId = _uuid.v4();

      await _db.orderDao.insertRow(
        OrdersCompanion.insert(
          id: orderId,
          orderNo: orderNo,
          customerId: request.customerId,
          branchId: request.branchId,
          orderDate: request.orderDate,
          trialDate: Value(request.trialDate),
          deliveryDate: request.deliveryDate,
          status: OrderStatus.booked,
          subtotal: pricing.subtotal,
          discount: pricing.discount,
          taxAmount: pricing.vatAmount,
          totalAmount: pricing.total,
          advancePaid: request.advanceAmount,
          balanceDue: balance,
          notes: Value(request.notes),
          createdBy: request.createdBy,
          createdAt: request.orderDate,
        ),
      );

      for (var i = 0; i < request.items.length; i++) {
        final item = request.items[i];
        await _db.orderItemDao.insertRow(
          OrderItemsCompanion.insert(
            id: _uuid.v4(),
            orderId: orderId,
            garmentTemplateId: item.garmentTemplateId,
            quantity: item.quantity,
            measurementsJson: item.measurementsJson,
            barcode: '$orderNoCore${(i + 1).toString().padLeft(2, '0')}',
            stage: OrderStatus.booked,
            fabricDetails: Value(item.fabricDetails),
            price: item.price,
            notes: Value(item.notes),
          ),
        );
      }

      if (request.advanceAmount > 0) {
        await _db.paymentDao.insertRow(
          PaymentsCompanion.insert(
            id: _uuid.v4(),
            orderId: orderId,
            amount: request.advanceAmount,
            mode: request.advanceMode ?? PaymentMode.cash,
            type: PaymentType.advance,
            receiptNo: 'R-$orderNoCore-1',
            collectedBy: request.createdBy,
            collectedAt: request.orderDate,
          ),
        );
      }

      final created = await getOrderById(orderId);
      return created!;
    });
  }

  @override
  Future<OrderWithItems> updateOrder(UpdateOrderRequest request) async {
    final order = await _db.orderDao.getById(request.orderId);
    if (order == null) throw OrderNotFoundException(request.orderId);
    if (order.status == OrderStatus.delivered) {
      throw OrderAlreadyFinalException(order.orderNo);
    }

    final discount = request.discount ?? order.discount;
    final pricing = OrderPricing.compute(
      subtotal: order.subtotal,
      discount: discount,
      vatRate: _rateOf(order),
    );

    await _db.orderDao.insertRow(
      order
          .copyWith(
            discount: pricing.discount,
            taxAmount: pricing.vatAmount,
            totalAmount: pricing.total,
            balanceDue: pricing.balanceAfter(order.advancePaid),
            trialDate: Value(request.trialDate ?? order.trialDate),
            deliveryDate: request.deliveryDate ?? order.deliveryDate,
            notes: Value(request.notes ?? order.notes),
          )
          .toCompanion(false),
    );

    return (await getOrderById(request.orderId))!;
  }

  @override
  Future<OrderWithItems> cancelOrder({
    required String orderId,
    required CancelledReason reason,
    required String cancelledBy,
    String? note,
    bool refundAdvance = false,
  }) async {
    final order = await _db.orderDao.getById(orderId);
    if (order == null) throw OrderNotFoundException(orderId);
    if (order.status == OrderStatus.delivered) {
      throw OrderAlreadyFinalException(order.orderNo);
    }

    return _db.transaction(() async {
      // Cancel every not-yet-delivered item; delivered ones stay delivered.
      final items = await _db.orderItemDao.getByOrder(orderId);
      for (final item in items) {
        if (item.stage == OrderStatus.delivered) continue;
        await _db.orderItemDao.insertRow(
          item.copyWith(stage: OrderStatus.cancelled).toCompanion(false),
        );
      }

      await _db.orderDao.insertRow(
        order
            .copyWith(
              status: OrderStatus.cancelled,
              cancelledReason: Value(reason),
              cancelledBy: Value(cancelledBy),
              refundAdvance: Value(refundAdvance),
              notes: Value(note ?? order.notes),
            )
            .toCompanion(false),
      );
      return (await getOrderById(orderId))!;
    });
  }

  @override
  Future<OrderWithItems> updateItemStage({
    required String orderItemId,
    required OrderStatus toStage,
    required String changedBy,
    String? note,
    bool whatsappTriggered = false,
  }) async {
    final item = await _db.orderItemDao.getById(orderItemId);
    if (item == null) throw OrderNotFoundException(orderItemId);

    return _db.transaction(() async {
      await _db.orderStatusHistoryDao.insertRow(
        OrderStatusHistoriesCompanion.insert(
          id: _uuid.v4(),
          orderItemId: orderItemId,
          fromStatus: item.stage,
          toStatus: toStage,
          changedBy: changedBy,
          changedAt: DateTime.now(),
          notes: Value(note),
          whatsappTriggered: whatsappTriggered,
        ),
      );
      await _db.orderItemDao.insertRow(
        item.copyWith(stage: toStage).toCompanion(false),
      );

      // Re-roll-up the parent order's status from all its items.
      final siblings = await _db.orderItemDao.getByOrder(item.orderId);
      final rolled = rollUpOrderStatus(siblings.map((s) => s.stage));
      final order = await _db.orderDao.getById(item.orderId);
      if (order != null && order.status != rolled) {
        await _db.orderDao.insertRow(
          order.copyWith(status: rolled).toCompanion(false),
        );
      }
      return (await getOrderById(item.orderId))!;
    });
  }

  @override
  Future<LastMeasurements?> lastMeasurementsFor({
    required String customerId,
    required String templateId,
  }) async {
    // The customer's orders, most recent first (exclude cancelled).
    final orders =
        (await _db.orderDao.getAll())
            .where((o) => o.customerId == customerId)
            .toList()
          ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    for (final order in orders) {
      if (order.status == OrderStatus.cancelled) continue;
      final items = await _db.orderItemDao.getByOrder(order.id);
      for (final item in items) {
        if (item.garmentTemplateId != templateId) continue;
        final values = parseMeasurementValues(item.measurementsJson);
        if (values.isNotEmpty) {
          return LastMeasurements(values: values, orderDate: order.orderDate);
        }
      }
    }
    return null;
  }

  // helpers

  /// `max(existing numeric order-no) + 1`, formatted `#TS-####`.
  Future<String> _nextOrderNo() async {
    final orders = await _db.orderDao.getAll();
    var maxNo = AppConfig.orderNoStart - 1;
    for (final o in orders) {
      final n = int.tryParse(_digitsOf(o.orderNo));
      if (n != null && n > maxNo) maxNo = n;
    }
    return '${AppConfig.orderNoPrefix}${maxNo + 1}';
  }

  /// The digit run of an order number (`#TS-1042` → `1042`).
  static String _digitsOf(String orderNo) =>
      orderNo.replaceAll(RegExp(r'[^0-9]'), '');

  /// VAT rate implied by an existing order's stored amounts (so an edit keeps the same rate).
  static double _rateOf(Order order) {
    final taxable = order.subtotal - order.discount;
    if (taxable <= 0) return AppConfig.defaultVatRate;
    return order.taxAmount / taxable;
  }
}

OrderStatus rollUpOrderStatus(Iterable<OrderStatus> itemStages) {
  final stages = itemStages.toList();
  if (stages.isEmpty) return OrderStatus.booked;

  final active = stages.where((s) => s != OrderStatus.cancelled).toList();
  if (active.isEmpty) return OrderStatus.cancelled;
  if (active.every((s) => s == OrderStatus.delivered)) {
    return OrderStatus.delivered;
  }

  // Least-advanced active stage (ignoring delivered items that are "done").
  const order = [
    OrderStatus.booked,
    OrderStatus.cutting,
    OrderStatus.stitching,
    OrderStatus.trial,
    OrderStatus.ready,
    OrderStatus.delivered,
  ];
  var min = OrderStatus.delivered;
  for (final s in active) {
    if (order.indexOf(s) < order.indexOf(min)) min = s;
  }
  return min;
}
