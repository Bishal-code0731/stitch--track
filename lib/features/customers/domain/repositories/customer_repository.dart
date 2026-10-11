import '../entities/customer_entity.dart';
import '../entities/new_customer_request.dart';

/// Customer data gateway.
abstract interface class CustomerRepository {
  /// Active customers matching [query] (by name or phone digits), newest first.
  Future<List<CustomerEntity>> search(String query);

  /// A single customer by id, or null.
  Future<CustomerEntity?> getById(String id);

  Future<CustomerEntity> createCustomer(NewCustomerRequest request);
}
