import 'package:drift/drift.dart';

import 'converters.dart';
import 'enums.dart';

// All 15 tables from `docs/02-data-model.md`.

@DataClassName('ShopProfile')
class ShopProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get shopName => text()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get address => text()();
  TextColumn get vatNumber => text()();
  TextColumn get invoiceContact => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Branch')
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get nameEn => text()();
  TextColumn get nameNe => text()();
  TextColumn get addressEn => text()();
  TextColumn get addressNe => text()();
  TextColumn get contactPhone => text()();
  BoolColumn get isActive => boolean()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('User')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get username => text()();
  TextColumn get roleId => text()();
  TextColumn get branchIds => text().map(const StringListConverter())();
  TextColumn get status => textEnum<UserStatus>()();
  TextColumn get passwordHash => text()();
  TextColumn get localePreference => textEnum<UserLocale>()();
  TextColumn get fcmToken => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Role')
class Roles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get permissionsJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Customer')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phonePrimary => text()();
  TextColumn get phoneAlternate => text().nullable()();
  TextColumn get gender => textEnum<Gender>().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GarmentTemplate')
class GarmentTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get nameEn => text()();
  TextColumn get nameNe => text()();
  TextColumn get defaultUnit => textEnum<GarmentUnit>()();
  TextColumn get fieldsJson => text()();
  RealColumn get basePrice => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Order')
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get orderNo => text()();
  TextColumn get customerId => text()();
  TextColumn get branchId => text()();
  DateTimeColumn get orderDate => dateTime()();
  DateTimeColumn get trialDate => dateTime().nullable()();
  DateTimeColumn get deliveryDate => dateTime()();
  TextColumn get status => textEnum<OrderStatus>()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real()();
  RealColumn get taxAmount => real()();
  RealColumn get totalAmount => real()();
  RealColumn get advancePaid => real()();
  RealColumn get balanceDue => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get cancelledReason => textEnum<CancelledReason>().nullable()();
  TextColumn get cancelledBy => text().nullable()();
  BoolColumn get refundAdvance => boolean().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OrderItem')
class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get garmentTemplateId => text()();
  IntColumn get quantity => integer()();
  TextColumn get measurementsJson => text()();
  TextColumn get barcode => text()();
  TextColumn get stage => textEnum<OrderStatus>()();
  TextColumn get fabricDetails => text().nullable()();
  RealColumn get price => real()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OrderItemAssignment')
class OrderItemAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get orderItemId => text()();
  TextColumn get workerId => text()();
  TextColumn get stage => textEnum<OrderStatus>()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OrderStatusHistory')
class OrderStatusHistories extends Table {
  TextColumn get id => text()();
  TextColumn get orderItemId => text()();
  TextColumn get fromStatus => textEnum<OrderStatus>()();
  TextColumn get toStatus => textEnum<OrderStatus>()();
  TextColumn get changedBy => text()();
  DateTimeColumn get changedAt => dateTime()();
  TextColumn get notes => text().nullable()();
  BoolColumn get whatsappTriggered => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Payment')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  RealColumn get amount => real()();
  TextColumn get mode => textEnum<PaymentMode>()();
  TextColumn get type => textEnum<PaymentType>()();
  TextColumn get receiptNo => text()();
  TextColumn get collectedBy => text()();
  DateTimeColumn get collectedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WhatsAppTemplate')
class WhatsAppTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get eventType => textEnum<WhatsAppEventType>()();
  TextColumn get bodyEn => text()();
  TextColumn get bodyNe => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppNotification')
class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get channel => textEnum<MessageChannel>()();
  TextColumn get triggerType => text()();
  TextColumn get templateId => text().nullable()();
  TextColumn get body => text()();
  TextColumn get status => textEnum<MessageStatus>()();
  DateTimeColumn get sentAt => dateTime().nullable()();
  IntColumn get retryCount => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AuditLog')
class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get deviceId => text()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OfflineActionQueueEntry')
class OfflineActionQueues extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get action => textEnum<OfflineAction>()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => textEnum<OfflineSyncStatus>()();

  @override
  Set<Column> get primaryKey => {id};
}
