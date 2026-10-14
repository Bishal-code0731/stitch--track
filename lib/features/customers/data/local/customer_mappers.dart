import '../../../../core/database/app_database.dart';
import '../../domain/entities/customer_entity.dart';

/// Drift-row → domain-entity mapper (kept in the data layer so the domain never imports Drift).
extension CustomerRowMapper on Customer {
  CustomerEntity toEntity() => CustomerEntity(
    id: id,
    name: name,
    phonePrimary: phonePrimary,
    phoneAlternate: phoneAlternate,
    gender: gender,
    address: address,
    notes: notes,
    isActive: isActive,
    createdAt: createdAt,
  );
}
