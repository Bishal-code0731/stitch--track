import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The active branch filter for the current session.
class ActiveBranchController extends Notifier<String?> {
  @override
  String? build() => null; // "All branches"

  /// Sets the active branch (`null` = all branches).
  void setBranch(String? branchId) => state = branchId;
}

/// Cross-feature session provider (lives in `core/` per the convention for shared providers).
final activeBranchProvider = NotifierProvider<ActiveBranchController, String?>(
  ActiveBranchController.new,
);
