import 'package:flutter/foundation.dart';

import '../../../../core/database/enums.dart';

/// The Add New Customer form's output.
@immutable
class NewCustomerRequest {
  const NewCustomerRequest({
    required this.name,
    required this.phonePrimary,
    this.phoneAlternate,
    this.gender,
    this.address,
    this.notes,
  });

  final String name;

  /// Local phone digits as typed (no country code); the repository normalizes.
  final String phonePrimary;
  final String? phoneAlternate;
  final Gender? gender;
  final String? address;
  final String? notes;
}
