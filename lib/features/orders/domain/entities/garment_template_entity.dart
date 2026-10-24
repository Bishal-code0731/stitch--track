import 'package:flutter/foundation.dart';

import '../../../../core/database/enums.dart';

@immutable
class GarmentTemplateEntity {
  const GarmentTemplateEntity({
    required this.id,
    required this.nameEn,
    required this.nameNe,
    required this.defaultUnit,
    required this.fieldsJson,
    required this.basePrice,
    required this.isActive,
  });

  final String id;
  final String nameEn;
  final String nameNe;
  final GarmentUnit defaultUnit;
  final String fieldsJson;

  /// Catalog price per garment of this type (Rs).
  final double basePrice;
  final bool isActive;

  /// Name in the given language code (`'ne'` → Nepali, else English).
  String name(String langCode) => langCode == 'ne' ? nameNe : nameEn;
}
