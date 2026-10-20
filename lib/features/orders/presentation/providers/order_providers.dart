import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/local/local_garment_template_repository.dart';
import '../../data/local/local_order_item_repository.dart';
import '../../data/local/local_order_repository.dart';
import '../../domain/entities/garment_template_entity.dart';
import '../../domain/repositories/garment_template_repository.dart';
import '../../domain/repositories/order_item_repository.dart';
import '../../domain/repositories/order_repository.dart';

/// The order repository the UI depends on.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return LocalOrderRepository(ref.watch(appDatabaseProvider));
});

/// Read-side per-garment lookups (barcode → item), feeding Phase 04's scanner.
final orderItemRepositoryProvider = Provider<OrderItemRepository>((ref) {
  return LocalOrderItemRepository(ref.watch(appDatabaseProvider));
});

/// The garment-template catalog gateway (order wizard Garments/Measurements).
final garmentTemplateRepositoryProvider = Provider<GarmentTemplateRepository>((
  ref,
) {
  return LocalGarmentTemplateRepository(ref.watch(appDatabaseProvider));
});

/// Active garment templates for the Garments step's grid.
final activeGarmentTemplatesProvider =
    FutureProvider<List<GarmentTemplateEntity>>((ref) {
      return ref.watch(garmentTemplateRepositoryProvider).getActiveTemplates();
    });

final lastMeasurementsProvider =
    FutureProvider.family<
      LastMeasurements?,
      ({String customerId, String templateId})
    >((ref, key) {
      return ref
          .watch(orderRepositoryProvider)
          .lastMeasurementsFor(
            customerId: key.customerId,
            templateId: key.templateId,
          );
    });
