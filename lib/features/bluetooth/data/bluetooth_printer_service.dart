import 'dart:io';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/entities/bluetooth_device.dart';

enum BluetoothPrinterConnectionStatus {
  none,
  connecting,
  connected,
  scanning,
  stopScanning,
}

class BluetoothPrinterService {
  final PrinterManager _printerManager = PrinterManager.instance;

  Future<bool> ensureBluetoothPermission() async {
    if (!Platform.isAndroid) return true;

    final permissions = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    final bluetoothGranted =
        permissions[Permission.bluetooth]?.isGranted ?? false;
    final connectGranted =
        permissions[Permission.bluetoothConnect]?.isGranted ?? false;
    final scanGranted =
        permissions[Permission.bluetoothScan]?.isGranted ?? false;
    final locationGranted =
        permissions[Permission.locationWhenInUse]?.isGranted ?? false;

    return locationGranted &&
        (bluetoothGranted || (connectGranted && scanGranted));
  }

  Stream<BluetoothDevice> scanDevices() {
    if (!Platform.isAndroid) return const Stream.empty();

    return _printerManager
        .discovery(type: PrinterType.bluetooth)
        .where((device) => device.address != null)
        .map(
          (device) => BluetoothDevice(
            name: device.name.trim().isEmpty ? 'Unknown device' : device.name,
            address: device.address!,
          ),
        );
  }

  Stream<BluetoothPrinterConnectionStatus> get connectionStatus {
    if (!Platform.isAndroid) return const Stream.empty();

    return _printerManager.stateBluetooth.map(_mapConnectionStatus);
  }

  BluetoothPrinterConnectionStatus get currentConnectionStatus {
    if (!Platform.isAndroid) return BluetoothPrinterConnectionStatus.none;

    return _mapConnectionStatus(_printerManager.currentStatusBT);
  }

  Future<bool> connect(BluetoothDevice device) async {
    if (!Platform.isAndroid) return false;

    await _printerManager.disconnect(type: PrinterType.bluetooth);

    return _printerManager.connect(
      type: PrinterType.bluetooth,
      model: BluetoothPrinterInput(name: device.name, address: device.address),
    );
  }

  Future<bool> testPrint() async {
    if (!Platform.isAndroid) return false;

    if (currentConnectionStatus != BluetoothPrinterConnectionStatus.connected) {
      return false;
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[
      ...generator.text(
        'Bakmi Balap 19',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...generator.text(
        'Test print berhasil',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...generator.feed(2),
    ];

    return _printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
  }

  BluetoothPrinterConnectionStatus _mapConnectionStatus(BTStatus status) {
    return switch (status) {
      BTStatus.connecting => BluetoothPrinterConnectionStatus.connecting,
      BTStatus.connected => BluetoothPrinterConnectionStatus.connected,
      BTStatus.scanning => BluetoothPrinterConnectionStatus.scanning,
      BTStatus.stopScanning => BluetoothPrinterConnectionStatus.stopScanning,
      BTStatus.none => BluetoothPrinterConnectionStatus.none,
    };
  }
}
