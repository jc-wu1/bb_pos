import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/confirm_order_payment_input.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/order_payment_method.dart';
import '../../../orders/domain/usecase/confirm_order_payment.dart';

part 'cash_payment_state.dart';

class CashPaymentCubit extends Cubit<CashPaymentState> {
  CashPaymentCubit({
    required ConfirmOrderPayment confirmOrderPayment,
    required OrderEntity? order,
  }) : _confirmOrderPayment = confirmOrderPayment,
       super(CashPaymentState.initial(order: order));

  final ConfirmOrderPayment _confirmOrderPayment;

  void setReceivedAmount(int amount) {
    if (state.isCompletingPayment) return;

    emit(
      state.copyWith(
        status: CashPaymentStatus.initial,
        receivedAmount: amount,
        clearChangeAmount: true,
        clearShortfallAmount: true,
        clearErrorMessage: true,
      ),
    );
  }

  void appendKey(String value) {
    if (state.isCompletingPayment) return;

    final nextValue = int.tryParse('${state.receivedAmount}$value') ?? 0;
    setReceivedAmount(nextValue);
  }

  void deleteKey() {
    if (state.isCompletingPayment || state.receivedAmount == 0) return;

    final text = state.receivedAmount.toString();
    final nextText = text.length == 1
        ? '0'
        : text.substring(0, text.length - 1);
    setReceivedAmount(int.parse(nextText));
  }

  void calculateChange() {
    if (state.isCompletingPayment) return;

    final order = state.order;
    if (order == null) return;

    final change = state.receivedAmount - order.totalAmount;
    if (change < 0) {
      emit(
        state.copyWith(
          status: CashPaymentStatus.initial,
          clearChangeAmount: true,
          shortfallAmount: change.abs(),
          clearErrorMessage: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: CashPaymentStatus.initial,
        changeAmount: change,
        clearShortfallAmount: true,
        clearErrorMessage: true,
      ),
    );
  }

  void resetPayment() {
    if (state.isCompletingPayment) return;

    emit(
      state.copyWith(
        status: CashPaymentStatus.initial,
        receivedAmount: 0,
        clearChangeAmount: true,
        clearShortfallAmount: true,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> completePayment() async {
    if (state.isCompletingPayment || state.changeAmount == null) return;

    final order = state.order;
    if (order == null) return;

    emit(
      state.copyWith(
        status: CashPaymentStatus.completing,
        clearShortfallAmount: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _confirmOrderPayment(
        ConfirmOrderPaymentInput(
          orderId: order.id,
          paymentMethod: OrderPaymentMethod.cash,
          amountPaid: state.receivedAmount,
          changeAmount: state.changeAmount!,
        ),
      );
      emit(
        state.copyWith(
          status: CashPaymentStatus.completed,
          noticeMessage: '${order.orderNumber} sudah completed.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CashPaymentStatus.failure,
          errorMessage: 'Pembayaran gagal diselesaikan.',
        ),
      );
    }
  }
}
