import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';

import '../../../orders/domain/entities/confirm_order_payment_input.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/order_payment_method.dart';
import '../../../orders/domain/usecase/confirm_order_payment.dart';

part 'qris_payment_state.dart';

class QrisPaymentCubit extends Cubit<QrisPaymentState> {
  QrisPaymentCubit({
    required ConfirmOrderPayment confirmOrderPayment,
    required OrderEntity? order,
  }) : _confirmOrderPayment = confirmOrderPayment,
       super(QrisPaymentState.initial(order: order)) {
    unawaited(startNotificationListener());
  }

  static const String _notificationPortName =
      'bb_pos_qris_payment_notification_port';
  static Future<void>? _initializeNotificationListenerFuture;

  final ConfirmOrderPayment _confirmOrderPayment;
  ReceivePort? _notificationPort;
  StreamSubscription<dynamic>? _notificationSubscription;
  bool _ownsNotificationPortMapping = false;
  bool _startedNotificationService = false;
  String? _lastHandledNotificationKey;

  Future<void> startNotificationListener() async {
    if (state.order == null || state.isCompletingPayment || isClosed) return;

    if (defaultTargetPlatform != TargetPlatform.android) {
      _emitIfOpen(
        state.copyWith(
          listenerStatus: QrisNotificationListenerStatus.failure,
          errorMessage: 'Listener notifikasi hanya tersedia di Android.',
        ),
      );
      return;
    }

    if (_notificationSubscription != null) return;

    _emitIfOpen(
      state.copyWith(
        listenerStatus: QrisNotificationListenerStatus.starting,
        clearErrorMessage: true,
      ),
    );

    try {
      await _setupNotificationPort();
      await _ensureNotificationPluginInitialized();

      final hasPermission =
          (await NotificationsListener.hasPermission) ?? false;
      if (!hasPermission) {
        await _disposeNotificationPort();
        _emitIfOpen(
          state.copyWith(
            listenerStatus: QrisNotificationListenerStatus.permissionRequired,
          ),
        );
        return;
      }

      final isRunning = (await NotificationsListener.isRunning) ?? false;
      if (!isRunning) {
        final started = await NotificationsListener.startService(
          foreground: false,
          title: 'BB POS QRIS Listener',
          description: 'Menunggu notifikasi pembayaran QRIS',
        );
        if (started == false) {
          throw StateError('Notification listener service did not start.');
        }
        _startedNotificationService = started ?? false;
      }

      _emitIfOpen(
        state.copyWith(listenerStatus: QrisNotificationListenerStatus.ready),
      );
    } catch (_) {
      await _disposeNotificationPort();
      _emitIfOpen(
        state.copyWith(
          listenerStatus: QrisNotificationListenerStatus.failure,
          errorMessage: 'Listener notifikasi QRIS gagal dimulai.',
        ),
      );
    }
  }

  Future<void> openNotificationPermissionSettings() async {
    await NotificationsListener.openPermissionSettings();
  }

  Future<void> _setupNotificationPort() async {
    await _disposeNotificationPort();

    final port = ReceivePort('qris-payment-notification-port');
    IsolateNameServer.removePortNameMapping(_notificationPortName);
    _ownsNotificationPortMapping = IsolateNameServer.registerPortWithName(
      port.sendPort,
      _notificationPortName,
    );

    if (!_ownsNotificationPortMapping) {
      port.close();
      throw StateError('Cannot register QRIS notification port.');
    }

    _notificationPort = port;
    _notificationSubscription = port.listen(_handleNotificationMessage);
  }

  Future<void> _disposeNotificationPort() async {
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;

    final port = _notificationPort;
    _notificationPort = null;

    if (_ownsNotificationPortMapping) {
      final registeredPort = IsolateNameServer.lookupPortByName(
        _notificationPortName,
      );
      if (registeredPort == port?.sendPort) {
        IsolateNameServer.removePortNameMapping(_notificationPortName);
      }
      _ownsNotificationPortMapping = false;
    }

    port?.close();
  }

  static Future<void> _ensureNotificationPluginInitialized() {
    return _initializeNotificationListenerFuture ??=
        NotificationsListener.initialize(callbackHandle: _notificationCallback);
  }

  @pragma('vm:entry-point')
  static void _notificationCallback(NotificationEvent event) {
    final sendPort = IsolateNameServer.lookupPortByName(_notificationPortName);
    sendPort?.send(event);
  }

  void _handleNotificationMessage(dynamic message) {
    if (isClosed ||
        state.isPaymentDetected ||
        state.isCompletingPayment ||
        state.status == QrisPaymentStatus.completed ||
        message is! NotificationEvent) {
      return;
    }

    final order = state.order;
    if (order == null || !_matchesSuccessfulQrisPayment(message, order)) {
      return;
    }

    final notificationKey = _notificationKey(message);
    if (_lastHandledNotificationKey == notificationKey) return;
    _lastHandledNotificationKey = notificationKey;

    _emitIfOpen(
      state.copyWith(
        isPaymentDetected: true,
        detectedNotificationTitle: message.title,
        detectedNotificationText: message.text ?? message.message,
        clearErrorMessage: true,
      ),
    );
  }

  bool _matchesSuccessfulQrisPayment(
    NotificationEvent event,
    OrderEntity order,
  ) {
    final content = _normalizedNotificationContent(event);

    if (!_containsPaymentService(content)) return false;
    if (!content.contains('qris')) return false;
    if (!_containsSuccessSignal(content)) return false;

    final amounts = _rupiahAmounts(content);
    return amounts.isEmpty || amounts.contains(order.totalAmount);
  }

  String _normalizedNotificationContent(NotificationEvent event) {
    final buffer = StringBuffer()
      ..write(' ')
      ..write(event.packageName ?? '')
      ..write(' ')
      ..write(event.title ?? '')
      ..write(' ')
      ..write(event.text ?? '')
      ..write(' ')
      ..write(event.message ?? '');

    final raw = event.raw;
    if (raw != null) {
      for (final key in const ['subText', 'summaryText']) {
        final value = raw[key];
        if (value != null) buffer.write(' $value');
      }

      final textLines = raw['textLines'];
      if (textLines is Iterable) {
        for (final line in textLines) {
          buffer.write(' $line');
        }
      }
    }

    return buffer.toString().toLowerCase();
  }

  bool _containsPaymentService(String content) {
    return _paymentServicePattern.hasMatch(content);
  }

  bool _containsSuccessSignal(String content) {
    return content.contains('berhasil') ||
        content.contains('sukses') ||
        content.contains('success') ||
        content.contains('successful') ||
        content.contains('diterima') ||
        content.contains('payment received') ||
        content.contains('paid');
  }

  Set<int> _rupiahAmounts(String content) {
    final amounts = <int>{};
    for (final match in _rupiahAmountPattern.allMatches(content)) {
      final rawAmount = match.group(1);
      if (rawAmount == null) continue;

      final amount = int.tryParse(rawAmount.replaceAll(RegExp(r'[^0-9]'), ''));
      if (amount != null && amount > 0) {
        amounts.add(amount);
      }
    }

    return amounts;
  }

  String _notificationKey(NotificationEvent event) {
    return event.uniqueId ??
        '${event.packageName}|${event.timestamp}|${event.title}|${event.text}';
  }

  Future<void> completePayment() async {
    if (state.isCompletingPayment) return;

    final order = state.order;
    if (order == null) return;

    emit(
      state.copyWith(
        status: QrisPaymentStatus.completing,
        clearErrorMessage: true,
      ),
    );

    try {
      await _confirmOrderPayment(
        ConfirmOrderPaymentInput(
          orderId: order.id,
          paymentMethod: OrderPaymentMethod.qris,
          amountPaid: order.totalAmount,
          changeAmount: 0,
        ),
      );
      emit(
        state.copyWith(
          status: QrisPaymentStatus.completed,
          noticeMessage: '${order.orderNumber} sudah completed.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: QrisPaymentStatus.failure,
          errorMessage: 'Pembayaran QRIS gagal diselesaikan.',
        ),
      );
    }
  }

  void _emitIfOpen(QrisPaymentState nextState) {
    if (!isClosed) emit(nextState);
  }

  @override
  Future<void> close() async {
    await _disposeNotificationPort();

    if (_startedNotificationService) {
      try {
        await NotificationsListener.stopService();
      } catch (_) {
        // The cubit is closing; there is no UI state left to report this to.
      }
    }

    return super.close();
  }
}

final RegExp _rupiahAmountPattern = RegExp(
  r'(?:rp|idr)\s*([0-9]+(?:[.,][0-9]{3})*)',
);

final RegExp _paymentServicePattern = RegExp(r'\b(mybca|bca|com\.bca)\b');
