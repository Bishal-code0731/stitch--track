import '../../../../core/database/app_database.dart';
import '../../domain/entities/order_entity.dart';

extension OrderRowMapper on Order {
  OrderEntity toEntity() => OrderEntity(
    id: id,
    orderNo: orderNo,
    customerId: customerId,
    branchId: branchId,
    orderDate: orderDate,
    trialDate: trialDate,
    deliveryDate: deliveryDate,
    status: status,
    subtotal: subtotal,
    discount: discount,
    taxAmount: taxAmount,
    totalAmount: totalAmount,
    advancePaid: advancePaid,
    balanceDue: balanceDue,
    notes: notes,
    cancelledReason: cancelledReason,
    cancelledBy: cancelledBy,
    refundAdvance: refundAdvance,
    createdBy: createdBy,
    createdAt: createdAt,
  );
}

extension OrderItemRowMapper on OrderItem {
  OrderItemEntity toEntity() => OrderItemEntity(
    id: id,
    orderId: orderId,
    garmentTemplateId: garmentTemplateId,
    quantity: quantity,
    measurementsJson: measurementsJson,
    barcode: barcode,
    stage: stage,
    fabricDetails: fabricDetails,
    price: price,
    notes: notes,
  );
}
