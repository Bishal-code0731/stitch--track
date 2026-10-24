import 'package:flutter/foundation.dart';

import '../../../../core/database/enums.dart';

/// One garment line in a [NewOrderRequest] — the wizard's Step 2/3 output for a single garment type.
@immutable
class NewOrderItem {
  const NewOrderItem({
    required this.garmentTemplateId,
    required this.quantity,
    required this.measurementsJson,
    required this.price,
    this.fabricDetails,
    this.notes,
  });

  final String garmentTemplateId;
  final int quantity;
  final String measurementsJson;
  final double price;
  final String? fabricDetails;
  final String? notes;
}

@immutable
class NewOrderRequest {
  const NewOrderRequest({
    required this.customerId,
    required this.branchId,
    required this.createdBy,
    required this.items,
    required this.orderDate,
    this.trialDate,
    required this.deliveryDate,
    this.discount = 0,
    this.vatRate,
    this.advanceAmount = 0,
    this.advanceMode,
    this.notes,
    this.sendWhatsApp = false,
  });

  final String customerId;
  final String branchId;
  final String createdBy;
  final List<NewOrderItem> items;
  final DateTime orderDate;
  final DateTime? trialDate;
  final DateTime deliveryDate;
  final double discount;

  /// VAT rate override; when null the repository uses `AppConfig.defaultVatRate`.
  final double? vatRate;

  final double advanceAmount;
  final PaymentMode? advanceMode;
  final String? notes;

  final bool sendWhatsApp;
}

/// Fields editable via `updateOrder` (Phase 03 Step 14).
@immutable
class UpdateOrderRequest {
  const UpdateOrderRequest({
    required this.orderId,
    this.discount,
    this.trialDate,
    this.deliveryDate,
    this.notes,
  });

  final String orderId;
  final double? discount;
  final DateTime? trialDate;
  final DateTime? deliveryDate;
  final String? notes;
}

/// Filter for the orders list (Phase 03 Step 9).
@immutable
class OrderFilter {
  const OrderFilter({
    this.status,
    this.customerId,
    this.garmentTemplateId,
    this.dueFrom,
    this.dueTo,
    this.search,
    this.includeCancelled = true,
  });

  /// Match a single lifecycle status (the rolled-up `Order.status`).
  final OrderStatus? status;
  final String? customerId;

  /// Match orders containing at least one item of this garment template.
  final String? garmentTemplateId;

  /// Delivery-date range (inclusive) for deadline filtering.
  final DateTime? dueFrom;
  final DateTime? dueTo;

  /// Free-text match against the order number (case-insensitive).
  final String? search;

  /// When false, cancelled orders are excluded regardless of [status].
  final bool includeCancelled;

  bool get isEmpty =>
      status == null &&
      customerId == null &&
      garmentTemplateId == null &&
      dueFrom == null &&
      dueTo == null &&
      (search == null || search!.trim().isEmpty) &&
      includeCancelled;
}
