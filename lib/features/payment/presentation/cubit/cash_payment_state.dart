part of 'cash_payment_cubit.dart';

const Object _stateFieldNotSet = Object();

enum CashPaymentStatus { initial, completing, completed, failure }

class CashPaymentState extends Equatable {
  const CashPaymentState({
    required this.status,
    required this.order,
    required this.receivedAmount,
    required this.changeAmount,
    required this.shortfallAmount,
    required this.errorMessage,
    required this.noticeMessage,
  });

  factory CashPaymentState.initial({required OrderEntity? order}) {
    return CashPaymentState(
      status: CashPaymentStatus.initial,
      order: order,
      receivedAmount: 0,
      changeAmount: null,
      shortfallAmount: null,
      errorMessage: null,
      noticeMessage: null,
    );
  }

  final CashPaymentStatus status;
  final OrderEntity? order;
  final int receivedAmount;
  final int? changeAmount;
  final int? shortfallAmount;
  final String? errorMessage;
  final String? noticeMessage;

  bool get isCompletingPayment => status == CashPaymentStatus.completing;

  bool get hasCalculatedChange => changeAmount != null;

  int get displayChangeAmount => changeAmount ?? 0;

  List<int> get quickAmounts {
    final total = order?.totalAmount;
    if (total == null) return const [];

    final roundedToFifty = ((total + 49999) ~/ 50000) * 50000;
    final roundedToHundred = ((total + 99999) ~/ 100000) * 100000;
    final amounts = <int>{
      50000,
      100000,
      roundedToFifty,
      roundedToHundred,
    }.where((amount) => amount > total).toList()..sort();

    return amounts.take(3).toList();
  }

  CashPaymentState copyWith({
    CashPaymentStatus? status,
    Object? order = _stateFieldNotSet,
    int? receivedAmount,
    Object? changeAmount = _stateFieldNotSet,
    bool clearChangeAmount = false,
    Object? shortfallAmount = _stateFieldNotSet,
    bool clearShortfallAmount = false,
    Object? errorMessage = _stateFieldNotSet,
    bool clearErrorMessage = false,
    Object? noticeMessage = _stateFieldNotSet,
  }) {
    final resolvedChangeAmount = clearChangeAmount
        ? null
        : identical(changeAmount, _stateFieldNotSet)
        ? this.changeAmount
        : changeAmount as int?;
    final resolvedShortfallAmount = clearShortfallAmount
        ? null
        : identical(shortfallAmount, _stateFieldNotSet)
        ? this.shortfallAmount
        : shortfallAmount as int?;
    final resolvedErrorMessage = clearErrorMessage
        ? null
        : identical(errorMessage, _stateFieldNotSet)
        ? this.errorMessage
        : errorMessage as String?;

    return CashPaymentState(
      status: status ?? this.status,
      order: identical(order, _stateFieldNotSet)
          ? this.order
          : order as OrderEntity?,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      changeAmount: resolvedChangeAmount,
      shortfallAmount: resolvedShortfallAmount,
      errorMessage: resolvedErrorMessage,
      noticeMessage: identical(noticeMessage, _stateFieldNotSet)
          ? this.noticeMessage
          : noticeMessage as String?,
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      order,
      receivedAmount,
      changeAmount,
      shortfallAmount,
      errorMessage,
      noticeMessage,
    ];
  }
}
