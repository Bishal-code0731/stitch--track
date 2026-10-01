import 'package:drift/drift.dart';

import 'app_database.dart';
import 'enums.dart';
import 'tables.dart';

part 'daos.g.dart';

// One DAO per table.

@DriftAccessor(tables: [ShopProfiles])
class ShopProfileDao extends DatabaseAccessor<AppDatabase>
    with _$ShopProfileDaoMixin {
  ShopProfileDao(super.db);
  Future<List<ShopProfile>> getAll() => select(shopProfiles).get();
  Future<ShopProfile?> getById(String id) =>
      (select(shopProfiles)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(ShopProfilesCompanion row) =>
      into(shopProfiles).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(shopProfiles)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Branches])
class BranchDao extends DatabaseAccessor<AppDatabase> with _$BranchDaoMixin {
  BranchDao(super.db);
  Future<List<Branch>> getAll() => select(branches).get();
  Stream<List<Branch>> watchAll() => select(branches).watch();
  Future<Branch?> getById(String id) =>
      (select(branches)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(BranchesCompanion row) =>
      into(branches).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(branches)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);
  Future<List<User>> getAll() => select(users).get();
  Future<User?> getById(String id) =>
      (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<User?> getByUsername(String username) => (select(
    users,
  )..where((t) => t.username.equals(username))).getSingleOrNull();
  Future<User?> getByPhone(String phone) =>
      (select(users)..where((t) => t.phone.equals(phone))).getSingleOrNull();
  Future<void> insertRow(UsersCompanion row) =>
      into(users).insertOnConflictUpdate(row);

  /// Full-row replace by primary key (e.g.
  Future<bool> updateRow(User row) => update(users).replace(row);
  Future<int> deleteById(String id) =>
      (delete(users)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Roles])
class RoleDao extends DatabaseAccessor<AppDatabase> with _$RoleDaoMixin {
  RoleDao(super.db);
  Future<List<Role>> getAll() => select(roles).get();
  Future<Role?> getById(String id) =>
      (select(roles)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(RolesCompanion row) =>
      into(roles).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(roles)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Customers])
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.db);
  Future<List<Customer>> getAll() => select(customers).get();
  Future<Customer?> getById(String id) =>
      (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(CustomersCompanion row) =>
      into(customers).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(customers)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [GarmentTemplates])
class GarmentTemplateDao extends DatabaseAccessor<AppDatabase>
    with _$GarmentTemplateDaoMixin {
  GarmentTemplateDao(super.db);
  Future<List<GarmentTemplate>> getAll() => select(garmentTemplates).get();
  Future<GarmentTemplate?> getById(String id) => (select(
    garmentTemplates,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(GarmentTemplatesCompanion row) =>
      into(garmentTemplates).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(garmentTemplates)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Orders])
class OrderDao extends DatabaseAccessor<AppDatabase> with _$OrderDaoMixin {
  OrderDao(super.db);
  Future<List<Order>> getAll() => select(orders).get();
  Future<List<Order>> getByBranch(String branchId) =>
      (select(orders)..where((t) => t.branchId.equals(branchId))).get();
  Future<Order?> getById(String id) =>
      (select(orders)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(OrdersCompanion row) =>
      into(orders).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(orders)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [OrderItems])
class OrderItemDao extends DatabaseAccessor<AppDatabase>
    with _$OrderItemDaoMixin {
  OrderItemDao(super.db);
  Future<List<OrderItem>> getAll() => select(orderItems).get();
  Future<List<OrderItem>> getByOrder(String orderId) =>
      (select(orderItems)..where((t) => t.orderId.equals(orderId))).get();
  Future<OrderItem?> getById(String id) =>
      (select(orderItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<OrderItem?> getByBarcode(String barcode) => (select(
    orderItems,
  )..where((t) => t.barcode.equals(barcode))).getSingleOrNull();

  Future<void> insertRow(OrderItemsCompanion row) =>
      into(orderItems).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(orderItems)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [OrderItemAssignments])
class OrderItemAssignmentDao extends DatabaseAccessor<AppDatabase>
    with _$OrderItemAssignmentDaoMixin {
  OrderItemAssignmentDao(super.db);
  Future<List<OrderItemAssignment>> getAll() =>
      select(orderItemAssignments).get();
  Future<List<OrderItemAssignment>> getByOrderItem(String orderItemId) =>
      (select(
        orderItemAssignments,
      )..where((t) => t.orderItemId.equals(orderItemId))).get();
  Future<OrderItemAssignment?> getById(String id) => (select(
    orderItemAssignments,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(OrderItemAssignmentsCompanion row) =>
      into(orderItemAssignments).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(orderItemAssignments)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [OrderStatusHistories])
class OrderStatusHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$OrderStatusHistoryDaoMixin {
  OrderStatusHistoryDao(super.db);
  Future<List<OrderStatusHistory>> getAll() =>
      select(orderStatusHistories).get();
  Future<List<OrderStatusHistory>> getByOrderItem(String orderItemId) =>
      (select(
        orderStatusHistories,
      )..where((t) => t.orderItemId.equals(orderItemId))).get();
  Future<OrderStatusHistory?> getById(String id) => (select(
    orderStatusHistories,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(OrderStatusHistoriesCompanion row) =>
      into(orderStatusHistories).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(orderStatusHistories)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Payments])
class PaymentDao extends DatabaseAccessor<AppDatabase> with _$PaymentDaoMixin {
  PaymentDao(super.db);
  Future<List<Payment>> getAll() => select(payments).get();
  Future<List<Payment>> getByOrder(String orderId) =>
      (select(payments)..where((t) => t.orderId.equals(orderId))).get();
  Future<Payment?> getById(String id) =>
      (select(payments)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(PaymentsCompanion row) =>
      into(payments).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(payments)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [WhatsAppTemplates])
class WhatsAppTemplateDao extends DatabaseAccessor<AppDatabase>
    with _$WhatsAppTemplateDaoMixin {
  WhatsAppTemplateDao(super.db);
  Future<List<WhatsAppTemplate>> getAll() => select(whatsAppTemplates).get();
  Future<WhatsAppTemplate?> getById(String id) => (select(
    whatsAppTemplates,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(WhatsAppTemplatesCompanion row) =>
      into(whatsAppTemplates).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(whatsAppTemplates)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Notifications])
class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);
  Future<List<AppNotification>> getAll() => select(notifications).get();
  Future<List<AppNotification>> getByOrder(String orderId) =>
      (select(notifications)..where((t) => t.orderId.equals(orderId))).get();
  Future<AppNotification?> getById(String id) =>
      (select(notifications)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(NotificationsCompanion row) =>
      into(notifications).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(notifications)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [AuditLogs])
class AuditLogDao extends DatabaseAccessor<AppDatabase>
    with _$AuditLogDaoMixin {
  AuditLogDao(super.db);
  Future<List<AuditLog>> getAll() => select(auditLogs).get();
  Future<AuditLog?> getById(String id) =>
      (select(auditLogs)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(AuditLogsCompanion row) =>
      into(auditLogs).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(auditLogs)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [OfflineActionQueues])
class OfflineActionQueueDao extends DatabaseAccessor<AppDatabase>
    with _$OfflineActionQueueDaoMixin {
  OfflineActionQueueDao(super.db);
  Future<List<OfflineActionQueueEntry>> getAll() =>
      select(offlineActionQueues).get();
  Future<List<OfflineActionQueueEntry>> getPending() => (select(
    offlineActionQueues,
  )..where((t) => t.syncStatus.equalsValue(OfflineSyncStatus.pending))).get();
  Future<OfflineActionQueueEntry?> getById(String id) => (select(
    offlineActionQueues,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> insertRow(OfflineActionQueuesCompanion row) =>
      into(offlineActionQueues).insertOnConflictUpdate(row);
  Future<int> deleteById(String id) =>
      (delete(offlineActionQueues)..where((t) => t.id.equals(id))).go();
}
