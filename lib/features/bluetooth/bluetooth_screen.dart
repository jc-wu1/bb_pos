import 'package:flutter/material.dart';

import 'presentation/bluetooth_settings_section.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: BluetoothSettingsSection(),
      ),
    );
  }
}
