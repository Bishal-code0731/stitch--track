import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/new_customer_request.dart';
import '../../domain/repositories/customer_repository.dart';
import 'customer_mappers.dart';

/// Drift-backed [CustomerRepository].
class LocalCustomerRepository implements CustomerRepository {
  LocalCustomerRepository(this._db, {Uuid? uuid, DateTime Function()? clock})
    : _uuid = uuid ?? const Uuid(),
      _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Future<List<CustomerEntity>> search(String query) async {
    final all = await _db.customerDao.getAll();
    final active = all.where((c) => c.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return active.map((c) => c.toEntity()).toList();

    final qDigits = q.replaceAll(RegExp(r'\D'), '');
    return active
        .where((c) {
          final nameHit = c.name.toLowerCase().contains(q);
          final phoneHit =
              qDigits.isNotEmpty &&
              c.phonePrimary.replaceAll(RegExp(r'\D'), '').contains(qDigits);
          return nameHit || phoneHit;
        })
        .map((c) => c.toEntity())
        .toList();
  }

  @override
  Future<CustomerEntity?> getById(String id) async =>
      (await _db.customerDao.getById(id))?.toEntity();

  @override
  Future<CustomerEntity> createCustomer(NewCustomerRequest request) async {
    final id = _uuid.v4();
    await _db.customerDao.insertRow(
      CustomersCompanion.insert(
        id: id,
        name: request.name.trim(),
        phonePrimary: _normalizePhone(request.phonePrimary),
        phoneAlternate: Value(
          request.phoneAlternate == null ||
                  request.phoneAlternate!.trim().isEmpty
              ? null
              : _normalizePhone(request.phoneAlternate!),
        ),
        gender: Value(request.gender),
        address: Value(_blankToNull(request.address)),
        notes: Value(_blankToNull(request.notes)),
        isActive: true,
        createdAt: _clock(),
      ),
    );
    return (await getById(id))!;
  }

  /// Stores phone as `+977XXXXXXXXXX`.
  static String _normalizePhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('+977')) {
      return '+977${trimmed.substring(4).replaceAll(RegExp(r'\D'), '')}';
    }
    return '+977${trimmed.replaceAll(RegExp(r'\D'), '')}';
  }

  static String? _blankToNull(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();
}
