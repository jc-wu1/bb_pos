part of 'bluetooth_bloc.dart';

const Object _stateFieldNotSet = Object();

enum BluetoothPermissionStatus { unknown, checking, granted, denied }

enum BluetoothDeviceListStatus { idle, loading, ready, failure }

class BluetoothState extends Equatable {
  const BluetoothState({
    required this.permissionStatus,
    required this.connectionStatus,
    required this.deviceListStatus,
    required this.devices,
    required this.selectedDevice,
    required this.connectingDeviceAddress,
    required this.isPrintingTest,
    required this.connectedDeviceSerial,
    required this.errorMessage,
    required this.errorSerial,
    required this.feedbackMessage,
    required this.feedbackSerial,
  });

  factory BluetoothState.initial() {
    return const BluetoothState(
      permissionStatus: BluetoothPermissionStatus.unknown,
      connectionStatus: BluetoothPrinterConnectionStatus.none,
      deviceListStatus: BluetoothDeviceListStatus.idle,
      devices: [],
      selectedDevice: null,
      connectingDeviceAddress: null,
      isPrintingTest: false,
      connectedDeviceSerial: 0,
      errorMessage: null,
      errorSerial: 0,
      feedbackMessage: null,
      feedbackSerial: 0,
    );
  }

  final BluetoothPermissionStatus permissionStatus;
  final BluetoothPrinterConnectionStatus connectionStatus;
  final BluetoothDeviceListStatus deviceListStatus;
  final List<BluetoothDevice> devices;
  final BluetoothDevice? selectedDevice;
  final String? connectingDeviceAddress;
  final bool isPrintingTest;
  final int connectedDeviceSerial;
  final String? errorMessage;
  final int errorSerial;
  final String? feedbackMessage;
  final int feedbackSerial;

  bool get hasBluetoothPermission {
    return permissionStatus == BluetoothPermissionStatus.granted;
  }

  bool get isCheckingPermission {
    return permissionStatus == BluetoothPermissionStatus.checking;
  }

  bool get isLoadingDevices {
    return deviceListStatus == BluetoothDeviceListStatus.loading;
  }

  bool get isConnected {
    return connectionStatus == BluetoothPrinterConnectionStatus.connected;
  }

  bool get isConnecting {
    return connectionStatus == BluetoothPrinterConnectionStatus.connecting ||
        connectingDeviceAddress != null;
  }

  bool get isScanning {
    return connectionStatus == BluetoothPrinterConnectionStatus.scanning;
  }

  BluetoothState copyWith({
    BluetoothPermissionStatus? permissionStatus,
    BluetoothPrinterConnectionStatus? connectionStatus,
    BluetoothDeviceListStatus? deviceListStatus,
    List<BluetoothDevice>? devices,
    Object? selectedDevice = _stateFieldNotSet,
    Object? connectingDeviceAddress = _stateFieldNotSet,
    bool? isPrintingTest,
    int? connectedDeviceSerial,
    Object? errorMessage = _stateFieldNotSet,
    bool clearErrorMessage = false,
    int? errorSerial,
    Object? feedbackMessage = _stateFieldNotSet,
    bool clearFeedbackMessage = false,
    int? feedbackSerial,
  }) {
    final resolvedErrorMessage = clearErrorMessage
        ? null
        : identical(errorMessage, _stateFieldNotSet)
        ? this.errorMessage
        : errorMessage as String?;
    final resolvedFeedbackMessage = clearFeedbackMessage
        ? null
        : identical(feedbackMessage, _stateFieldNotSet)
        ? this.feedbackMessage
        : feedbackMessage as String?;

    return BluetoothState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      deviceListStatus: deviceListStatus ?? this.deviceListStatus,
      devices: devices ?? this.devices,
      selectedDevice: identical(selectedDevice, _stateFieldNotSet)
          ? this.selectedDevice
          : selectedDevice as BluetoothDevice?,
      connectingDeviceAddress:
          identical(connectingDeviceAddress, _stateFieldNotSet)
          ? this.connectingDeviceAddress
          : connectingDeviceAddress as String?,
      isPrintingTest: isPrintingTest ?? this.isPrintingTest,
      connectedDeviceSerial:
          connectedDeviceSerial ?? this.connectedDeviceSerial,
      errorMessage: resolvedErrorMessage,
      errorSerial: errorSerial ?? this.errorSerial,
      feedbackMessage: resolvedFeedbackMessage,
      feedbackSerial: feedbackSerial ?? this.feedbackSerial,
    );
  }

  @override
  List<Object?> get props {
    return [
      permissionStatus,
      connectionStatus,
      deviceListStatus,
      devices,
      selectedDevice,
      connectingDeviceAddress,
      isPrintingTest,
      connectedDeviceSerial,
      errorMessage,
      errorSerial,
      feedbackMessage,
      feedbackSerial,
    ];
  }
}
