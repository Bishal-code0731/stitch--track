/// Order-domain failures.
sealed class OrderException implements Exception {
  const OrderException(this.message);
  final String message;

  @override
  String toString() => 'OrderException: $message';
}

/// No order (or order item) exists for the given id.
class OrderNotFoundException extends OrderException {
  const OrderNotFoundException(String id)
    : super('No order found for id "$id".');
}

/// An order was submitted with no line items.
class EmptyOrderException extends OrderException {
  const EmptyOrderException() : super('An order must have at least one item.');
}

class OrderAlreadyFinalException extends OrderException {
  const OrderAlreadyFinalException(String orderNo)
    : super('Order $orderNo is delivered and can no longer be changed.');
}

/// A stage transition that the lifecycle doesn't allow.
class InvalidStageTransitionException extends OrderException {
  const InvalidStageTransitionException(super.message);
}
