part of 'qris_payment_cubit.dart';

const Object _qrisStateFieldNotSet = Object();

enum QrisPaymentStatus { initial, completing, completed, failure }

enum QrisNotificationListenerStatus {
  initial,
  starting,
  ready,
  permissionRequired,
  failure,
}

class QrisPaymentState extends Equatable {
  const QrisPaymentState({
    required this.status,
    required this.listenerStatus,
    required this.order,
    required this.isPaymentDetected,
    required this.detectedNotificationTitle,
    required this.detectedNotificationText,
    required this.errorMessage,
    required this.noticeMessage,
  });

  factory QrisPaymentState.initial({required OrderEntity? order}) {
    return QrisPaymentState(
      status: QrisPaymentStatus.initial,
      listenerStatus: QrisNotificationListenerStatus.initial,
      order: order,
      isPaymentDetected: false,
      detectedNotificationTitle: null,
      detectedNotificationText: null,
      errorMessage: null,
      noticeMessage: null,
    );
  }

  final QrisPaymentStatus status;
  final QrisNotificationListenerStatus listenerStatus;
  final OrderEntity? order;
  final bool isPaymentDetected;
  final String? detectedNotificationTitle;
  final String? detectedNotificationText;
  final String? errorMessage;
  final String? noticeMessage;

  bool get isCompletingPayment => status == QrisPaymentStatus.completing;

  QrisPaymentState copyWith({
    QrisPaymentStatus? status,
    QrisNotificationListenerStatus? listenerStatus,
    Object? order = _qrisStateFieldNotSet,
    bool? isPaymentDetected,
    Object? detectedNotificationTitle = _qrisStateFieldNotSet,
    Object? detectedNotificationText = _qrisStateFieldNotSet,
    Object? errorMessage = _qrisStateFieldNotSet,
    bool clearErrorMessage = false,
    Object? noticeMessage = _qrisStateFieldNotSet,
  }) {
    final resolvedErrorMessage = clearErrorMessage
        ? null
        : identical(errorMessage, _qrisStateFieldNotSet)
        ? this.errorMessage
        : errorMessage as String?;

    return QrisPaymentState(
      status: status ?? this.status,
      listenerStatus: listenerStatus ?? this.listenerStatus,
      order: identical(order, _qrisStateFieldNotSet)
          ? this.order
          : order as OrderEntity?,
      isPaymentDetected: isPaymentDetected ?? this.isPaymentDetected,
      detectedNotificationTitle:
          identical(detectedNotificationTitle, _qrisStateFieldNotSet)
          ? this.detectedNotificationTitle
          : detectedNotificationTitle as String?,
      detectedNotificationText:
          identical(detectedNotificationText, _qrisStateFieldNotSet)
          ? this.detectedNotificationText
          : detectedNotificationText as String?,
      errorMessage: resolvedErrorMessage,
      noticeMessage: identical(noticeMessage, _qrisStateFieldNotSet)
          ? this.noticeMessage
          : noticeMessage as String?,
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      listenerStatus,
      order,
      isPaymentDetected,
      detectedNotificationTitle,
      detectedNotificationText,
      errorMessage,
      noticeMessage,
    ];
  }
}
