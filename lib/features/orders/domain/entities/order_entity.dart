import 'package:flutter/foundation.dart';

import '../../../../core/database/enums.dart';

@immutable
class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.orderNo,
    required this.customerId,
    required this.branchId,
    required this.orderDate,
    this.trialDate,
    required this.deliveryDate,
    required this.status,
    required this.subtotal,
    required this.discount,
    required this.taxAmount,
    required this.totalAmount,
    required this.advancePaid,
    required this.balanceDue,
    this.notes,
    this.cancelledReason,
    this.cancelledBy,
    this.refundAdvance,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String orderNo;
  final String customerId;
  final String branchId;
  final DateTime orderDate;
  final DateTime? trialDate;
  final DateTime deliveryDate;
  final OrderStatus status;
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double totalAmount;
  final double advancePaid;
  final double balanceDue;
  final String? notes;
  final CancelledReason? cancelledReason;
  final String? cancelledBy;
  final bool? refundAdvance;
  final String createdBy;
  final DateTime createdAt;

  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isDelivered => status == OrderStatus.delivered;
}

/// A pure-Dart order line item (one garment type × quantity), mirroring the `OrderItems` table.
@immutable
class OrderItemEntity {
  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.garmentTemplateId,
    required this.quantity,
    required this.measurementsJson,
    required this.barcode,
    required this.stage,
    this.fabricDetails,
    required this.price,
    this.notes,
  });

  final String id;
  final String orderId;
  final String garmentTemplateId;
  final int quantity;
  final String measurementsJson;
  final String barcode;
  final OrderStatus stage;
  final String? fabricDetails;
  final double price;
  final String? notes;
}

@immutable
class OrderWithItems {
  const OrderWithItems({required this.order, required this.items});

  final OrderEntity order;
  final List<OrderItemEntity> items;
}
