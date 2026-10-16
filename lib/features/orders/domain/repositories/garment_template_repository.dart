import '../entities/garment_template_entity.dart';

abstract interface class GarmentTemplateRepository {
  /// All active garment templates, in a stable display order.
  Future<List<GarmentTemplateEntity>> getActiveTemplates();

  /// A single template by id, or null.
  Future<GarmentTemplateEntity?> getById(String id);
}
