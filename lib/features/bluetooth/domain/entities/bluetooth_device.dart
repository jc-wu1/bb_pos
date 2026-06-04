import 'package:equatable/equatable.dart';

class BluetoothDevice extends Equatable {
  const BluetoothDevice({required this.name, required this.address});

  final String name;
  final String address;

  @override
  List<Object> get props => [name, address];
}
