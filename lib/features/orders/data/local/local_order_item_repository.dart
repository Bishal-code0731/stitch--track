import '../../../../core/database/app_database.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_item_repository.dart';
import 'order_mappers.dart';

/// Drift-backed [OrderItemRepository] — read-side per-garment lookups.
class LocalOrderItemRepository implements OrderItemRepository {
  LocalOrderItemRepository(this._db);

  final AppDatabase _db;

  @override
  Future<OrderItemEntity?> getByBarcode(String barcode) async =>
      (await _db.orderItemDao.getByBarcode(barcode))?.toEntity();

  @override
  Future<OrderItemEntity?> getById(String id) async =>
      (await _db.orderItemDao.getById(id))?.toEntity();

  @override
  Future<List<OrderItemEntity>> getByOrder(String orderId) async =>
      (await _db.orderItemDao.getByOrder(
        orderId,
      )).map((i) => i.toEntity()).toList();
}
