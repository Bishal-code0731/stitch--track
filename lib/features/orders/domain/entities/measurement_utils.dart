import 'dart:convert';

import '../../../../core/database/enums.dart';

/// Field ids in order from a template's `fieldsJson` (`[{"field_name":"chest",...}, …]`).
List<String> parseTemplateFields(String fieldsJson) {
  try {
    final decoded = jsonDecode(fieldsJson);
    if (decoded is! List) return const [];
    return [
      for (final e in decoded)
        if (e is Map && e['field_name'] is String)
          e['field_name'] as String
        else if (e is String)
          e,
    ];
  } catch (_) {
    return const [];
  }
}

/// The numeric measurement values from an `OrderItem.measurementsJson` (`{"unit":"in","chest":40,…}`).
Map<String, double> parseMeasurementValues(String measurementsJson) {
  try {
    final decoded = jsonDecode(measurementsJson);
    if (decoded is! Map) return {};
    final out = <String, double>{};
    decoded.forEach((k, v) {
      if (k == 'unit') return;
      if (v is num) out[k as String] = v.toDouble();
    });
    return out;
  } catch (_) {
    return {};
  }
}

/// Serializes measurement [values] + [unit] to the stored JSON shape (`{"unit":"in","chest":40,…}`).
String encodeMeasurements(Map<String, double> values, GarmentUnit unit) {
  return jsonEncode({
    'unit': unit == GarmentUnit.inch ? 'in' : 'cm',
    ...values,
  });
}

/// inch → cm, rounded to the nearest 0.5 (the cm entry step).
double inchToCm(double inches) => (inches * 2.54 * 2).round() / 2;

/// cm → inch, rounded to the nearest 0.25 (the inch entry step).
double cmToInch(double cm) => (cm / 2.54 * 4).round() / 4;

/// Converts a value between units (no-op when [from] == [to]).
double convertMeasurement(double value, GarmentUnit from, GarmentUnit to) {
  if (from == to) return value;
  return from == GarmentUnit.inch ? inchToCm(value) : cmToInch(value);
}

/// The entry step for a unit: 0.25 in, 0.5 cm.
double stepFor(GarmentUnit unit) => unit == GarmentUnit.inch ? 0.25 : 0.5;
