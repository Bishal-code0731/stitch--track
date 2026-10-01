import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../utils/password_hasher.dart';
import 'app_database.dart';
import 'enums.dart';

/// Demo password for every seeded staff account (Phase 02 login testing).
const String kSeedDemoPassword = 'Passw0rd!';

Future<void> seedDatabase(
  AppDatabase db, {
  bool force = false,
  DateTime? now,
}) async {
  if (!kDebugMode && !force) return;
  final existing = await db.select(db.branches).get();
  if (existing.isNotEmpty && !force) return;

  final t = now ?? DateTime(2026, 7, 22, 10);
  DateTime days(int d) => t.add(Duration(days: d));

  // Shop + branches
  const bMain = 'br-ktm', bLal = 'br-lalitpur', bBkt = 'br-bhaktapur';
  await db.batch((b) {
    b.insert(
      db.shopProfiles,
      ShopProfilesCompanion.insert(
        id: 'shop-1',
        shopName: 'Everest Tailors',
        address: 'New Road, Kathmandu',
        vatNumber: '301234567',
        invoiceContact: '+977-1-4000000',
      ),
    );
    b.insertAll(db.branches, [
      BranchesCompanion.insert(
        id: bMain,
        nameEn: 'Kathmandu (Main)',
        nameNe: 'काठमाडौँ (मुख्य)',
        addressEn: 'New Road, Kathmandu',
        addressNe: 'नयाँ सडक, काठमाडौँ',
        contactPhone: '+977-1-4000001',
        isActive: true,
        createdAt: t,
      ),
      BranchesCompanion.insert(
        id: bLal,
        nameEn: 'Lalitpur',
        nameNe: 'ललितपुर',
        addressEn: 'Pulchowk, Lalitpur',
        addressNe: 'पुल्चोक, ललितपुर',
        contactPhone: '+977-1-4000002',
        isActive: true,
        createdAt: t,
      ),
      BranchesCompanion.insert(
        id: bBkt,
        nameEn: 'Bhaktapur',
        nameNe: 'भक्तपुर',
        addressEn: 'Durbar Sq., Bhaktapur',
        addressNe: 'दरबार स्क्वायर, भक्तपुर',
        contactPhone: '+977-1-4000003',
        isActive: false,
        createdAt: t,
      ),
    ]);
  });

  // Roles + staff
  const rAdmin = 'role-admin',
      rCounter = 'role-counter',
      rWorker = 'role-worker';
  await db.batch((b) {
    b.insertAll(db.roles, [
      RolesCompanion.insert(
        id: rAdmin,
        name: 'Admin',
        permissionsJson: '["*"]',
      ),
      RolesCompanion.insert(
        id: rCounter,
        name: 'Counter',
        permissionsJson: '["orders.create","customers.manage"]',
      ),
      RolesCompanion.insert(
        id: rWorker,
        name: 'Production Worker',
        permissionsJson: '["orders.advance_stage"]',
      ),
    ]);
    b.insertAll(db.users, [
      UsersCompanion.insert(
        id: 'u-admin',
        name: 'Anil Shrestha',
        phone: '+9779800000001',
        username: 'admin',
        roleId: rAdmin,
        branchIds: const [bMain, bLal, bBkt],
        status: UserStatus.active,
        passwordHash: hashPassword(kSeedDemoPassword),
        localePreference: UserLocale.en,
        createdAt: t,
      ),
      UsersCompanion.insert(
        id: 'u-counter',
        name: 'Gita Karki',
        phone: '+9779800000002',
        username: 'counter1',
        roleId: rCounter,
        branchIds: const [bMain],
        status: UserStatus.active,
        passwordHash: hashPassword(kSeedDemoPassword),
        localePreference: UserLocale.ne,
        createdAt: t,
      ),
      UsersCompanion.insert(
        id: 'u-worker1',
        name: 'Hari Bahadur',
        phone: '+9779800000003',
        username: 'worker1',
        roleId: rWorker,
        branchIds: const [bMain, bLal],
        status: UserStatus.active,
        passwordHash: hashPassword(kSeedDemoPassword),
        localePreference: UserLocale.ne,
        createdAt: t,
      ),
      UsersCompanion.insert(
        id: 'u-worker2',
        name: 'Maya Tamang',
        phone: '+9779800000004',
        username: 'worker2',
        roleId: rWorker,
        branchIds: const [bLal],
        status: UserStatus.active,
        passwordHash: hashPassword(kSeedDemoPassword),
        localePreference: UserLocale.ne,
        createdAt: t,
      ),
      UsersCompanion.insert(
        id: 'u-pending',
        name: 'Suresh Rai',
        phone: '+9779800000005',
        username: 'pending1',
        roleId: rCounter,
        branchIds: const [bBkt],
        status: UserStatus.pendingApproval,
        passwordHash: hashPassword(kSeedDemoPassword),
        localePreference: UserLocale.en,
        createdAt: t,
      ),
    ]);
  });

  // Customers
  const c1 = 'cust-1', c2 = 'cust-2', c3 = 'cust-3';
  await db.batch((b) {
    b.insertAll(db.customers, [
      CustomersCompanion.insert(
        id: c1,
        name: 'Bishal Joshi',
        phonePrimary: '+9779811111111',
        gender: const Value(Gender.male),
        isActive: true,
        createdAt: t,
      ),
      CustomersCompanion.insert(
        id: c2,
        name: 'Sita Rai',
        phonePrimary: '+9779822222222',
        gender: const Value(Gender.female),
        isActive: true,
        createdAt: t,
      ),
      CustomersCompanion.insert(
        id: c3,
        name: 'Ramesh Thapa',
        phonePrimary: '+9779833333333',
        gender: const Value(Gender.male),
        isActive: true,
        createdAt: t,
      ),
    ]);
  });

  // Bilingual garment templates
  String fields(List<String> f) => jsonEncode([
    for (final n in f) {'field_name': n, 'default_value': ''},
  ]);
  const gShirt = 'g-shirt',
      gSuit = 'g-suit',
      gTrouser = 'g-trouser',
      gBlouse = 'g-blouse';
  await db.batch((b) {
    b.insertAll(db.garmentTemplates, [
      GarmentTemplatesCompanion.insert(
        id: gShirt,
        nameEn: 'Shirt',
        nameNe: 'सर्ट',
        defaultUnit: GarmentUnit.inch,
        fieldsJson: fields([
          'chest',
          'waist',
          'shoulder',
          'sleeve',
          'length',
          'collar',
        ]),
        basePrice: const Value(1500),
        isActive: true,
        createdAt: t,
      ),
      GarmentTemplatesCompanion.insert(
        id: gSuit,
        nameEn: 'Suit',
        nameNe: 'सुट',
        defaultUnit: GarmentUnit.inch,
        fieldsJson: fields(['chest', 'waist', 'shoulder', 'sleeve', 'length']),
        basePrice: const Value(9200),
        isActive: true,
        createdAt: t,
      ),
      GarmentTemplatesCompanion.insert(
        id: gTrouser,
        nameEn: 'Trousers',
        nameNe: 'पाइन्ट',
        defaultUnit: GarmentUnit.inch,
        fieldsJson: fields(['waist', 'hip', 'length', 'thigh']),
        basePrice: const Value(2000),
        isActive: true,
        createdAt: t,
      ),
      GarmentTemplatesCompanion.insert(
        id: gBlouse,
        nameEn: 'Blouse',
        nameNe: 'ब्लाउज',
        defaultUnit: GarmentUnit.cm,
        fieldsJson: fields(['bust', 'waist', 'shoulder', 'length']),
        basePrice: const Value(2600),
        isActive: true,
        createdAt: t,
      ),
    ]);
  });

  // WhatsApp templates (bilingual)
  await db.batch((b) {
    b.insertAll(db.whatsAppTemplates, [
      WhatsAppTemplatesCompanion.insert(
        id: 'wt-confirmed',
        eventType: WhatsAppEventType.orderConfirmed,
        bodyEn:
            'Hi {customer_name}, your order {order_no} at {shop_name} is confirmed.',
        bodyNe:
            'नमस्ते {customer_name}, {shop_name} मा तपाईंको अर्डर {order_no} पुष्टि भयो।',
        isActive: true,
      ),
      WhatsAppTemplatesCompanion.insert(
        id: 'wt-trial',
        eventType: WhatsAppEventType.trialReminder,
        bodyEn: 'Reminder: trial for order {order_no} on {date}.',
        bodyNe: 'सम्झना: अर्डर {order_no} को ट्रायल {date} मा।',
        isActive: true,
      ),
      WhatsAppTemplatesCompanion.insert(
        id: 'wt-ready',
        eventType: WhatsAppEventType.readyForPickup,
        bodyEn:
            'Good news {customer_name}! Order {order_no} is ready for pickup.',
        bodyNe: 'खुसीको खबर {customer_name}! अर्डर {order_no} लिन तयार छ।',
        isActive: true,
      ),
    ]);
  });

  await db.batch((b) {
    b.insertAll(db.orders, [
      _order(
        'ord-1',
        '#TS-0001',
        c1,
        bMain,
        days(-5),
        OrderStatus.stitching,
        5200,
        orderDate: days(-5),
        deliveryDate: days(3),
        advance: 2000,
        createdBy: 'u-counter',
      ),
      _order(
        'ord-2',
        '#TS-0002',
        c2,
        bMain,
        days(-4),
        OrderStatus.trial,
        2600,
        orderDate: days(-4),
        trialDate: days(1),
        deliveryDate: days(4),
        advance: 1000,
        createdBy: 'u-counter',
      ),
      _order(
        'ord-3',
        '#TS-0003',
        c3,
        bLal,
        days(-8),
        OrderStatus.ready,
        1800,
        orderDate: days(-8),
        deliveryDate: days(-1),
        advance: 1800,
        createdBy: 'u-counter',
      ),
      _order(
        'ord-4',
        '#TS-0004',
        c1,
        bLal,
        days(-14),
        OrderStatus.delivered,
        4000,
        orderDate: days(-14),
        deliveryDate: days(-6),
        advance: 4000,
        createdBy: 'u-counter',
      ),
      _order(
        'ord-5',
        '#TS-0005',
        c2,
        bMain,
        days(0),
        OrderStatus.booked,
        3000,
        orderDate: days(0),
        deliveryDate: days(7),
        advance: 0,
        createdBy: 'u-counter',
      ),
    ]);
    b.insertAll(db.orderItems, [
      _item('oi-1a', 'ord-1', gShirt, 'TS-0001-1', OrderStatus.stitching, 2200),
      _item('oi-1b', 'ord-1', gSuit, 'TS-0001-2', OrderStatus.cutting, 3000),
      _item('oi-2a', 'ord-2', gBlouse, 'TS-0002-1', OrderStatus.trial, 2600),
      _item('oi-3a', 'ord-3', gTrouser, 'TS-0003-1', OrderStatus.ready, 1800),
      _item('oi-4a', 'ord-4', gSuit, 'TS-0004-1', OrderStatus.delivered, 4000),
      _item('oi-5a', 'ord-5', gShirt, 'TS-0005-1', OrderStatus.booked, 3000),
    ]);
  });

  // Assignments, history, payments, message, audit, offline queue
  await db.batch((b) {
    b.insert(
      db.orderItemAssignments,
      OrderItemAssignmentsCompanion.insert(
        id: 'as-1',
        orderItemId: 'oi-1a',
        workerId: 'u-worker1',
        stage: OrderStatus.stitching,
        startedAt: Value(days(-1)),
      ),
    );
    b.insertAll(db.orderStatusHistories, [
      OrderStatusHistoriesCompanion.insert(
        id: 'h-1',
        orderItemId: 'oi-1a',
        fromStatus: OrderStatus.cutting,
        toStatus: OrderStatus.stitching,
        changedBy: 'u-worker1',
        changedAt: days(-1),
        whatsappTriggered: false,
      ),
      OrderStatusHistoriesCompanion.insert(
        id: 'h-2',
        orderItemId: 'oi-3a',
        fromStatus: OrderStatus.stitching,
        toStatus: OrderStatus.ready,
        changedBy: 'u-worker2',
        changedAt: days(-1),
        whatsappTriggered: true,
      ),
    ]);
    b.insertAll(db.payments, [
      PaymentsCompanion.insert(
        id: 'pay-1',
        orderId: 'ord-1',
        amount: 2000,
        mode: PaymentMode.cash,
        type: PaymentType.advance,
        receiptNo: 'RC-0001',
        collectedBy: 'u-counter',
        collectedAt: days(-5),
      ),
      PaymentsCompanion.insert(
        id: 'pay-2',
        orderId: 'ord-4',
        amount: 4000,
        mode: PaymentMode.upi,
        type: PaymentType.balance,
        receiptNo: 'RC-0002',
        collectedBy: 'u-counter',
        collectedAt: days(-6),
      ),
    ]);
    b.insert(
      db.notifications,
      NotificationsCompanion.insert(
        id: 'msg-1',
        orderId: 'ord-1',
        channel: MessageChannel.whatsapp,
        triggerType: 'order_confirmed',
        templateId: const Value('wt-confirmed'),
        body:
            'Hi Bishal Joshi, your order #TS-0001 at Everest Tailors is confirmed.',
        status: MessageStatus.delivered,
        sentAt: Value(days(-5)),
        retryCount: 0,
      ),
    );
    b.insertAll(db.auditLogs, [
      AuditLogsCompanion.insert(
        id: 'al-1',
        userId: 'u-counter',
        action: 'create',
        entityType: 'Order',
        entityId: 'ord-1',
        branchId: const Value(bMain),
        deviceId: 'dev-counter-1',
        timestamp: days(-5),
      ),
      AuditLogsCompanion.insert(
        id: 'al-2',
        userId: 'u-worker1',
        action: 'advance_stage',
        entityType: 'OrderItem',
        entityId: 'oi-1a',
        branchId: const Value(bMain),
        deviceId: 'dev-worker-1',
        timestamp: days(-1),
      ),
    ]);
    b.insert(
      db.offlineActionQueues,
      OfflineActionQueuesCompanion.insert(
        id: 'oq-1',
        entityType: 'OrderItem',
        action: OfflineAction.update,
        payloadJson: jsonEncode({'id': 'oi-2a', 'stage': 'trial'}),
        createdAt: days(0),
        syncStatus: OfflineSyncStatus.pending,
      ),
    );
  });
}

OrdersCompanion _order(
  String id,
  String orderNo,
  String customerId,
  String branchId,
  DateTime _,
  OrderStatus status,
  double total, {
  required DateTime orderDate,
  DateTime? trialDate,
  required DateTime deliveryDate,
  required double advance,
  required String createdBy,
}) {
  return OrdersCompanion.insert(
    id: id,
    orderNo: orderNo,
    customerId: customerId,
    branchId: branchId,
    orderDate: orderDate,
    trialDate: Value(trialDate),
    deliveryDate: deliveryDate,
    status: status,
    subtotal: total,
    discount: 0,
    taxAmount: total * 0.13, // VAT 13%
    totalAmount: total,
    advancePaid: advance,
    balanceDue: total - advance,
    createdBy: createdBy,
    createdAt: orderDate,
  );
}

OrderItemsCompanion _item(
  String id,
  String orderId,
  String garmentTemplateId,
  String barcode,
  OrderStatus stage,
  double price,
) {
  return OrderItemsCompanion.insert(
    id: id,
    orderId: orderId,
    garmentTemplateId: garmentTemplateId,
    quantity: 1,
    measurementsJson: '{"unit":"in"}',
    barcode: barcode,
    stage: stage,
    price: price,
  );
}
