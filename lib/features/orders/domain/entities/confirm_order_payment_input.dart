import 'package:equatable/equatable.dart';

import 'order_payment_method.dart';

class ConfirmOrderPaymentInput extends Equatable {
  const ConfirmOrderPaymentInput({
    required this.orderId,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
  });

  final int orderId;
  final OrderPaymentMethod paymentMethod;
  final int amountPaid;
  final int changeAmount;

  @override
  List<Object?> get props {
    return [orderId, paymentMethod, amountPaid, changeAmount];
  }
}
