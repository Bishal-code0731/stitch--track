import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../data/local/local_customer_repository.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';

/// The customer repository the UI depends on.
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return LocalCustomerRepository(ref.watch(appDatabaseProvider));
});

@immutable
class CustomerPickerItem {
  const CustomerPickerItem({
    required this.customer,
    required this.orderCount,
    this.lastOrderDate,
  });

  final CustomerEntity customer;
  final int orderCount;
  final DateTime? lastOrderDate;
}

/// Search results for the New Order customer picker, keyed by the query string.
final customerPickerResultsProvider =
    FutureProvider.family<List<CustomerPickerItem>, String>((ref, query) async {
      final customers = await ref
          .watch(customerRepositoryProvider)
          .search(query);
      final orders = await ref.watch(orderRepositoryProvider).getOrders();

      final counts = <String, int>{};
      final latest = <String, DateTime>{};
      for (final o in orders) {
        counts[o.customerId] = (counts[o.customerId] ?? 0) + 1;
        final prev = latest[o.customerId];
        if (prev == null || o.orderDate.isAfter(prev)) {
          latest[o.customerId] = o.orderDate;
        }
      }

      return customers
          .map(
            (c) => CustomerPickerItem(
              customer: c,
              orderCount: counts[c.id] ?? 0,
              lastOrderDate: latest[c.id],
            ),
          )
          .toList();
    });

final customerStatsProvider =
    FutureProvider.family<({int count, DateTime? last}), String>((
      ref,
      customerId,
    ) async {
      final orders = await ref.watch(orderRepositoryProvider).getOrders();
      final mine = orders.where((o) => o.customerId == customerId).toList();
      if (mine.isEmpty) return (count: 0, last: null);
      var last = mine.first.orderDate;
      for (final o in mine) {
        if (o.orderDate.isAfter(last)) last = o.orderDate;
      }
      return (count: mine.length, last: last);
    });
