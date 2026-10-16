import '../../../../core/database/app_database.dart';
import '../../domain/entities/garment_template_entity.dart';
import '../../domain/repositories/garment_template_repository.dart';

extension _GarmentTemplateRowMapper on GarmentTemplate {
  GarmentTemplateEntity toEntity() => GarmentTemplateEntity(
    id: id,
    nameEn: nameEn,
    nameNe: nameNe,
    defaultUnit: defaultUnit,
    fieldsJson: fieldsJson,
    basePrice: basePrice,
    isActive: isActive,
  );
}

/// Drift-backed [GarmentTemplateRepository].
class LocalGarmentTemplateRepository implements GarmentTemplateRepository {
  LocalGarmentTemplateRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<GarmentTemplateEntity>> getActiveTemplates() async {
    final rows = await _db.garmentTemplateDao.getAll();
    return (rows.where((t) => t.isActive).toList()
          ..sort((a, b) => a.nameEn.compareTo(b.nameEn)))
        .map((t) => t.toEntity())
        .toList();
  }

  @override
  Future<GarmentTemplateEntity?> getById(String id) async =>
      (await _db.garmentTemplateDao.getById(id))?.toEntity();
}
