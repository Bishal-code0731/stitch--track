import 'package:flutter/foundation.dart';

@immutable
class OrderPricing {
  const OrderPricing({
    required this.subtotal,
    required this.discount,
    required this.vatRate,
    required this.vatAmount,
    required this.total,
  });

  /// Sum of every line's `price × quantity`, before discount and VAT.
  final double subtotal;

  /// Flat discount applied to the subtotal (absolute amount, not a rate).
  final double discount;

  /// VAT rate as a fraction (e.g.
  final double vatRate;

  /// VAT charged on the post-discount taxable amount.
  final double vatAmount;

  /// Grand total the customer owes.
  final double total;

  /// The taxable base VAT is charged on (`subtotal − discount`, never below 0).
  double get taxable =>
      _round2((subtotal - discount).clamp(0, double.infinity));

  /// Computes the breakdown from a [subtotal], optional [discount], and [vatRate].
  factory OrderPricing.compute({
    required double subtotal,
    double discount = 0,
    required double vatRate,
  }) {
    final sub = _round2(subtotal);
    final disc = _round2(discount.clamp(0, sub));
    final taxable = sub - disc;
    final vat = _round2(taxable * vatRate);
    final total = _round2(taxable + vat);
    return OrderPricing(
      subtotal: sub,
      discount: disc,
      vatRate: vatRate,
      vatAmount: vat,
      total: total,
    );
  }

  /// The balance still owed after an [advance] payment.
  double balanceAfter(double advance) =>
      _round2((total - advance).clamp(0, double.infinity));

  @override
  String toString() =>
      'OrderPricing(subtotal: $subtotal, discount: $discount, '
      'vat: $vatAmount @ $vatRate, total: $total)';
}

/// Rounds to 2 decimal places (paisa), matching how amounts are displayed.
double _round2(double v) => (v * 100).round() / 100;

/// Sums line prices (`price × quantity`) into a subtotal.
double orderSubtotal(Iterable<({double price, int quantity})> lines) {
  var sum = 0.0;
  for (final line in lines) {
    sum += line.price * line.quantity;
  }
  return (sum * 100).round() / 100;
}
