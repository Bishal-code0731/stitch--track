import 'package:flutter/foundation.dart';

import '../../../../core/database/enums.dart';

/// A pure-Dart customer, decoupled from Drift (the repository maps the `Customers` row to this).
@immutable
class CustomerEntity {
  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phonePrimary,
    this.phoneAlternate,
    this.gender,
    this.address,
    this.notes,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phonePrimary;
  final String? phoneAlternate;
  final Gender? gender;
  final String? address;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
}
