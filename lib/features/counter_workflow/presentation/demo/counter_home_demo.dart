import 'package:flutter/foundation.dart';

import '../../../../core/theme/colors.dart';

/// A bilingual (English / Nepali) display string pair.
@immutable
class DemoText {
  const DemoText(this.en, this.ne);

  final String en;
  final String ne;

  /// Picks the string for a language code (`'ne'` → Nepali, else English).
  String resolve(String langCode) => langCode == 'ne' ? ne : en;
}

/// Order-level status shown on the Counter Home cards.
enum CounterOrderStatus { inProduction, ready, delayed, isNew }

extension CounterOrderStatusStyle on CounterOrderStatus {
  StatusColor get colors {
    switch (this) {
      case CounterOrderStatus.inProduction:
        return StatusColors.cutting; // blue
      case CounterOrderStatus.ready:
        return StatusColors.ready; // green
      case CounterOrderStatus.delayed:
        return StatusColors.overdue; // red
      case CounterOrderStatus.isNew:
        return StatusColors.delivered; // neutral grey
    }
  }

  /// i18n key for the pill label.
  String get labelKey {
    switch (this) {
      case CounterOrderStatus.inProduction:
        return 'counter_status_progress';
      case CounterOrderStatus.ready:
        return 'counter_status_ready';
      case CounterOrderStatus.delayed:
        return 'counter_status_delayed';
      case CounterOrderStatus.isNew:
        return 'counter_status_new';
    }
  }
}

/// One recent order as shown on the Counter Home list.
@immutable
class CounterHomeOrder {
  const CounterHomeOrder({
    required this.id,
    required this.customerName,
    required this.initials,
    required this.itemCount,
    required this.items,
    required this.status,
    required this.priority,
    required this.due,
    required this.overdue,
  });

  final String id;
  final DemoText customerName;
  final String initials;
  final int itemCount;
  final DemoText items;
  final CounterOrderStatus status;
  final bool priority;
  final DemoText due;
  final bool overdue;
}

const DemoText demoCounterBranch = DemoText('New Road', 'नयाँ सडक');

// Quick-stat values (mirror the mockup)
const int demoTodayOrders = 8;
const int demoTrialsToday = 3;
const int demoReadyForPickup = 5;
const num demoPendingBalance = 18400;

/// Recent orders, in the mockup's order.
const List<CounterHomeOrder> demoRecentOrders = [
  CounterHomeOrder(
    id: 'TS-1042',
    customerName: DemoText('Ramesh Shrestha', 'रमेश श्रेष्ठ'),
    initials: 'RS',
    itemCount: 2,
    items: DemoText('Daura Suruwal, Trouser', 'दौरा सुरुवाल, पाइन्ट'),
    status: CounterOrderStatus.inProduction,
    priority: true,
    due: DemoText('12 Jun', '१२ जुन'),
    overdue: false,
  ),
  CounterHomeOrder(
    id: 'TS-1041',
    customerName: DemoText('Sita Gurung', 'सीता गुरुङ'),
    initials: 'SG',
    itemCount: 2,
    items: DemoText('Blouse, Sari Blouse', 'ब्लाउज, चोलो'),
    status: CounterOrderStatus.ready,
    priority: false,
    due: DemoText('11 Jun', '११ जुन'),
    overdue: false,
  ),
  CounterHomeOrder(
    id: 'TS-1039',
    customerName: DemoText('Bibek Thapa', 'विवेक थापा'),
    initials: 'BT',
    itemCount: 1,
    items: DemoText('Suit', 'सुट'),
    status: CounterOrderStatus.delayed,
    priority: false,
    due: DemoText('6 Jun', '६ जुन'),
    overdue: true,
  ),
  CounterHomeOrder(
    id: 'TS-1038',
    customerName: DemoText('Anjali Maharjan', 'अञ्जली महर्जन'),
    initials: 'AM',
    itemCount: 1,
    items: DemoText('Kurta', 'कुर्ता'),
    status: CounterOrderStatus.ready,
    priority: false,
    due: DemoText('9 Jun', '९ जुन'),
    overdue: false,
  ),
  CounterHomeOrder(
    id: 'TS-1036',
    customerName: DemoText('Prakash Tamang', 'प्रकाश तामाङ'),
    initials: 'PT',
    itemCount: 3,
    items: DemoText('Shirt ×3', 'शर्ट ×३'),
    status: CounterOrderStatus.isNew,
    priority: false,
    due: DemoText('14 Jun', '१४ जुन'),
    overdue: false,
  ),
];
