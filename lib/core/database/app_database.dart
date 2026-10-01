import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection/connection.dart';
import 'converters.dart';
import 'daos.dart';
import 'enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The StitchTrack local database — the single source of truth pre-Phase-09.
@DriftDatabase(
  tables: [
    ShopProfiles,
    Branches,
    Users,
    Roles,
    Customers,
    GarmentTemplates,
    Orders,
    OrderItems,
    OrderItemAssignments,
    OrderStatusHistories,
    Payments,
    WhatsAppTemplates,
    Notifications,
    AuditLogs,
    OfflineActionQueues,
  ],
  daos: [
    ShopProfileDao,
    BranchDao,
    UserDao,
    RoleDao,
    CustomerDao,
    GarmentTemplateDao,
    OrderDao,
    OrderItemDao,
    OrderItemAssignmentDao,
    OrderStatusHistoryDao,
    PaymentDao,
    WhatsAppTemplateDao,
    NotificationDao,
    AuditLogDao,
    OfflineActionQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
    },
  );
}

/// App-wide database instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
