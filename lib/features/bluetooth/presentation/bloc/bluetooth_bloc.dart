import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/bluetooth_printer_service.dart';
import '../../domain/entities/bluetooth_device.dart';

part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  BluetoothBloc({required BluetoothPrinterService bluetoothPrinterService})
    : _bluetoothPrinterService = bluetoothPrinterService,
      super(BluetoothState.initial()) {
    on<BluetoothStarted>(_onStarted);
    on<BluetoothDevicesRequested>(_onDevicesRequested);
    on<BluetoothDeviceSelected>(_onDeviceSelected);
    on<BluetoothTestPrintRequested>(_onTestPrintRequested);
    on<BluetoothDeviceDiscovered>(_onDeviceDiscovered);
    on<BluetoothScanFinished>(_onScanFinished);
    on<BluetoothScanFailed>(_onScanFailed);
    on<BluetoothConnectionStatusChanged>(_onConnectionStatusChanged);
  }

  final BluetoothPrinterService _bluetoothPrinterService;
  StreamSubscription<BluetoothDevice>? _scanSubscription;
  StreamSubscription<BluetoothPrinterConnectionStatus>? _statusSubscription;

  Future<void> _onStarted(
    BluetoothStarted event,
    Emitter<BluetoothState> emit,
  ) async {
    emit(
      state.copyWith(
        permissionStatus: BluetoothPermissionStatus.checking,
        clearErrorMessage: true,
      ),
    );

    try {
      _statusSubscription ??= _bluetoothPrinterService.connectionStatus.listen(
        (status) => add(BluetoothConnectionStatusChanged(status)),
      );
      final permissionGranted = await _bluetoothPrinterService
          .ensureBluetoothPermission();

      emit(
        state.copyWith(
          permissionStatus: permissionGranted
              ? BluetoothPermissionStatus.granted
              : BluetoothPermissionStatus.denied,
          connectionStatus: _bluetoothPrinterService.currentConnectionStatus,
          errorMessage: permissionGranted
              ? null
              : 'Izin Bluetooth belum diberikan.',
          errorSerial: permissionGranted
              ? state.errorSerial
              : state.errorSerial + 1,
        ),
      );
    } catch (_) {
      _emitFailure(emit, 'Izin Bluetooth belum bisa diperiksa.');
    }
  }

  Future<void> _onDevicesRequested(
    BluetoothDevicesRequested event,
    Emitter<BluetoothState> emit,
  ) async {
    await _scanSubscription?.cancel();
    emit(
      state.copyWith(
        deviceListStatus: BluetoothDeviceListStatus.loading,
        devices: const [],
        clearErrorMessage: true,
      ),
    );

    try {
      final permissionGranted = await _ensurePermissionForAction(emit);
      if (!permissionGranted) return;

      _scanSubscription = _bluetoothPrinterService.scanDevices().listen(
        (device) => add(BluetoothDeviceDiscovered(device)),
        onError: (Object error, StackTrace stackTrace) {
          add(const BluetoothScanFailed());
        },
        onDone: () => add(const BluetoothScanFinished()),
      );
    } catch (_) {
      _emitFailure(emit, 'Perangkat Bluetooth belum bisa dimuat.');
    }
  }

  Future<void> _onDeviceSelected(
    BluetoothDeviceSelected event,
    Emitter<BluetoothState> emit,
  ) async {
    if (state.connectingDeviceAddress != null) return;

    emit(
      state.copyWith(
        connectingDeviceAddress: event.device.address,
        clearErrorMessage: true,
      ),
    );

    try {
      final connected = await _bluetoothPrinterService.connect(event.device);
      if (!connected) {
        _emitConnectionFailure(emit);
        return;
      }

      emit(
        state.copyWith(
          selectedDevice: event.device,
          connectingDeviceAddress: null,
          connectionStatus: _bluetoothPrinterService.currentConnectionStatus,
          connectedDeviceSerial: state.connectedDeviceSerial + 1,
          feedbackMessage: 'Perangkat berhasil terhubung.',
          feedbackSerial: state.feedbackSerial + 1,
        ),
      );
    } catch (_) {
      _emitConnectionFailure(emit);
    }
  }

  void _onDeviceDiscovered(
    BluetoothDeviceDiscovered event,
    Emitter<BluetoothState> emit,
  ) {
    if (state.devices.any((device) => device.address == event.device.address)) {
      return;
    }

    emit(state.copyWith(devices: [...state.devices, event.device]));
  }

  void _onScanFinished(
    BluetoothScanFinished event,
    Emitter<BluetoothState> emit,
  ) {
    emit(state.copyWith(deviceListStatus: BluetoothDeviceListStatus.ready));
  }

  void _onScanFailed(BluetoothScanFailed event, Emitter<BluetoothState> emit) {
    _emitFailure(emit, 'Perangkat Bluetooth belum bisa dimuat.');
  }

  void _onConnectionStatusChanged(
    BluetoothConnectionStatusChanged event,
    Emitter<BluetoothState> emit,
  ) {
    emit(state.copyWith(connectionStatus: event.status));
  }

  Future<void> _onTestPrintRequested(
    BluetoothTestPrintRequested event,
    Emitter<BluetoothState> emit,
  ) async {
    if (state.isPrintingTest) return;

    if (state.selectedDevice == null) {
      _emitFailure(emit, 'Pilih perangkat Bluetooth terlebih dahulu.');
      return;
    }

    emit(state.copyWith(isPrintingTest: true, clearErrorMessage: true));

    try {
      final printed = await _bluetoothPrinterService.testPrint();
      if (!printed) {
        _emitFailure(emit, 'Test print gagal dikirim.');
        return;
      }

      emit(
        state.copyWith(
          isPrintingTest: false,
          feedbackMessage: 'Test print berhasil dikirim.',
          feedbackSerial: state.feedbackSerial + 1,
        ),
      );
    } catch (_) {
      _emitFailure(emit, 'Test print gagal dikirim.');
    }
  }

  Future<bool> _ensurePermissionForAction(Emitter<BluetoothState> emit) async {
    final permissionGranted = await _bluetoothPrinterService
        .ensureBluetoothPermission();

    emit(
      state.copyWith(
        permissionStatus: permissionGranted
            ? BluetoothPermissionStatus.granted
            : BluetoothPermissionStatus.denied,
      ),
    );

    if (permissionGranted) return true;

    _emitFailure(emit, 'Izin Bluetooth belum diberikan.');
    return false;
  }

  void _emitFailure(Emitter<BluetoothState> emit, String message) {
    emit(
      state.copyWith(
        deviceListStatus:
            state.deviceListStatus == BluetoothDeviceListStatus.loading
            ? BluetoothDeviceListStatus.failure
            : state.deviceListStatus,
        connectingDeviceAddress: null,
        isPrintingTest: false,
        errorMessage: message,
        errorSerial: state.errorSerial + 1,
      ),
    );
  }

  void _emitConnectionFailure(Emitter<BluetoothState> emit) {
    emit(
      state.copyWith(
        selectedDevice: null,
        connectingDeviceAddress: null,
        errorMessage: 'Perangkat gagal terhubung.',
        errorSerial: state.errorSerial + 1,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _scanSubscription?.cancel();
    await _statusSubscription?.cancel();
    return super.close();
  }
}
