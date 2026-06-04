part of 'bluetooth_bloc.dart';

sealed class BluetoothEvent extends Equatable {
  const BluetoothEvent();

  @override
  List<Object?> get props => [];
}

class BluetoothStarted extends BluetoothEvent {
  const BluetoothStarted();
}

class BluetoothDevicesRequested extends BluetoothEvent {
  const BluetoothDevicesRequested();
}

class BluetoothDeviceSelected extends BluetoothEvent {
  const BluetoothDeviceSelected(this.device);

  final BluetoothDevice device;

  @override
  List<Object?> get props => [device];
}

class BluetoothTestPrintRequested extends BluetoothEvent {
  const BluetoothTestPrintRequested();
}

class BluetoothDeviceDiscovered extends BluetoothEvent {
  const BluetoothDeviceDiscovered(this.device);

  final BluetoothDevice device;

  @override
  List<Object?> get props => [device];
}

class BluetoothScanFinished extends BluetoothEvent {
  const BluetoothScanFinished();
}

class BluetoothScanFailed extends BluetoothEvent {
  const BluetoothScanFailed();
}

class BluetoothConnectionStatusChanged extends BluetoothEvent {
  const BluetoothConnectionStatusChanged(this.status);

  final BluetoothPrinterConnectionStatus status;

  @override
  List<Object?> get props => [status];
}
