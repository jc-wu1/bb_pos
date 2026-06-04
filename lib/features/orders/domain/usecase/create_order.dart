import '../repositories/orders_repository.dart';

class CreateOrder {
  const CreateOrder(this._repository);

  final OrdersRepository _repository;

  Future<int> call() {
    return _repository.createOrder();
  }
}
