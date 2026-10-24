import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/enums.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../domain/entities/measurement_utils.dart';

/// One garment line the wizard is building (Step 2 Garments).
@immutable
class WizardGarment {
  const WizardGarment({
    required this.uid,
    required this.templateId,
    this.quantity = 1,
    this.note = '',
    this.measurements = const {},
    this.saveAsTemplate = false,
  });

  final int uid;
  final String templateId;
  final int quantity;
  final String note;

  /// Field-id → value, in the wizard's current [OrderWizardState.unit].
  final Map<String, double> measurements;

  final bool saveAsTemplate;

  WizardGarment copyWith({
    int? quantity,
    String? note,
    Map<String, double>? measurements,
    bool? saveAsTemplate,
  }) => WizardGarment(
    uid: uid,
    templateId: templateId,
    quantity: quantity ?? this.quantity,
    note: note ?? this.note,
    measurements: measurements ?? this.measurements,
    saveAsTemplate: saveAsTemplate ?? this.saveAsTemplate,
  );
}

@immutable
class OrderWizardState {
  const OrderWizardState({
    this.customer,
    this.garments = const [],
    this.unit = GarmentUnit.inch,
    this.discount = 0,
    this.advanceAmount = 0,
    this.advanceMode = PaymentMode.cash,
    this.trialDate,
    this.deliveryDate,
    this.sendWhatsApp = true,
  });

  final CustomerEntity? customer;
  final List<WizardGarment> garments;

  final GarmentUnit unit;

  // Review (Step 4) inputs
  final double discount;
  final double advanceAmount;
  final PaymentMode advanceMode;
  final DateTime? trialDate;
  final DateTime? deliveryDate;
  final bool sendWhatsApp;

  bool get hasCustomer => customer != null;

  /// Total pieces across all lines (sum of quantities).
  int get totalPieces => garments.fold(0, (sum, g) => sum + g.quantity);

  /// Pieces of a given template across all lines (drives the grid count badge).
  int quantityOfTemplate(String templateId) => garments
      .where((g) => g.templateId == templateId)
      .fold(0, (sum, g) => sum + g.quantity);

  OrderWizardState copyWith({
    CustomerEntity? customer,
    List<WizardGarment>? garments,
    GarmentUnit? unit,
    double? discount,
    double? advanceAmount,
    PaymentMode? advanceMode,
    DateTime? trialDate,
    DateTime? deliveryDate,
    bool? sendWhatsApp,
  }) => OrderWizardState(
    customer: customer ?? this.customer,
    garments: garments ?? this.garments,
    unit: unit ?? this.unit,
    discount: discount ?? this.discount,
    advanceAmount: advanceAmount ?? this.advanceAmount,
    advanceMode: advanceMode ?? this.advanceMode,
    trialDate: trialDate ?? this.trialDate,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    sendWhatsApp: sendWhatsApp ?? this.sendWhatsApp,
  );

  /// Clears the customer (copyWith can't set it back to null); keeps the rest.
  OrderWizardState withoutCustomer() => OrderWizardState(
    garments: garments,
    unit: unit,
    discount: discount,
    advanceAmount: advanceAmount,
    advanceMode: advanceMode,
    trialDate: trialDate,
    deliveryDate: deliveryDate,
    sendWhatsApp: sendWhatsApp,
  );
}

/// Holds the New Order wizard draft.
class OrderWizardController extends Notifier<OrderWizardState> {
  int _nextUid = 1;

  @override
  OrderWizardState build() => const OrderWizardState();

  /// Begins a fresh wizard (call from the "New Order" entry point).
  void reset() {
    _nextUid = 1;
    state = const OrderWizardState();
  }

  void selectCustomer(CustomerEntity customer) =>
      state = state.copyWith(customer: customer);

  void clearCustomer() => state = state.withoutCustomer();

  void addGarment(String templateId) {
    state = state.copyWith(
      garments: [
        ...state.garments,
        WizardGarment(uid: _nextUid++, templateId: templateId),
      ],
    );
  }

  void setQuantity(int uid, int quantity) {
    if (quantity < 1) {
      removeGarment(uid);
      return;
    }
    _mutate(uid, (g) => g.copyWith(quantity: quantity));
  }

  void setNote(int uid, String note) =>
      _mutate(uid, (g) => g.copyWith(note: note));

  void removeGarment(int uid) {
    state = state.copyWith(
      garments: state.garments.where((g) => g.uid != uid).toList(),
    );
  }

  /// Sets one measurement field on a line (clamped to ≥ 0).
  void setMeasurement(int uid, String fieldId, double value) {
    _mutate(uid, (g) {
      final next = Map<String, double>.from(g.measurements);
      next[fieldId] = value < 0 ? 0 : value;
      return g.copyWith(measurements: next);
    });
  }

  /// Replaces a line's measurements wholesale (used by "Reuse last").
  void reuseMeasurements(int uid, Map<String, double> values) =>
      _mutate(uid, (g) => g.copyWith(measurements: Map.of(values)));

  void setSaveAsTemplate(int uid, bool value) =>
      _mutate(uid, (g) => g.copyWith(saveAsTemplate: value));

  void setUnit(GarmentUnit unit) {
    if (unit == state.unit) return;
    final from = state.unit;
    state = state.copyWith(
      unit: unit,
      garments: [
        for (final g in state.garments)
          g.copyWith(
            measurements: {
              for (final e in g.measurements.entries)
                e.key: convertMeasurement(e.value, from, unit),
            },
          ),
      ],
    );
  }

  // Review (Step 4) setters

  void setDiscount(double value) =>
      state = state.copyWith(discount: value < 0 ? 0 : value);

  void setAdvance(double value) =>
      state = state.copyWith(advanceAmount: value < 0 ? 0 : value);

  void setAdvanceMode(PaymentMode mode) =>
      state = state.copyWith(advanceMode: mode);

  void setTrialDate(DateTime date) => state = state.copyWith(trialDate: date);

  void setDeliveryDate(DateTime date) =>
      state = state.copyWith(deliveryDate: date);

  void setSendWhatsApp(bool value) =>
      state = state.copyWith(sendWhatsApp: value);

  void ensureScheduleDefaults(DateTime now) {
    state = state.copyWith(
      trialDate: state.trialDate ?? now.add(const Duration(days: 7)),
      deliveryDate: state.deliveryDate ?? now.add(const Duration(days: 14)),
    );
  }

  void _mutate(int uid, WizardGarment Function(WizardGarment) f) {
    state = state.copyWith(
      garments: [
        for (final g in state.garments)
          if (g.uid == uid) f(g) else g,
      ],
    );
  }
}

final orderWizardProvider =
    NotifierProvider<OrderWizardController, OrderWizardState>(
      OrderWizardController.new,
    );
