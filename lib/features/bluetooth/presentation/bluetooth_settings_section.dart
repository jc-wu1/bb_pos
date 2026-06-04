import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/dependencies/injector.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../domain/entities/bluetooth_device.dart';
import 'bloc/bluetooth_bloc.dart';

class BluetoothSettingsSection extends StatelessWidget {
  const BluetoothSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BluetoothBloc>()..add(const BluetoothStarted()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BluetoothBloc, BluetoothState>(
      listenWhen: (previous, current) {
        return previous.errorSerial != current.errorSerial ||
            previous.feedbackSerial != current.feedbackSerial;
      },
      listener: (context, state) {
        final message = state.errorMessage ?? state.feedbackMessage;
        if (message == null) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        return _ConnectedDeviceCard(state: state);
      },
    );
  }
}

class _ConnectedDeviceCard extends StatelessWidget {
  const _ConnectedDeviceCard({required this.state});

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedDevice = state.selectedDevice;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.bluetooth_connected, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Connected Device',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(
                label: _statusLabel(state),
                color: _statusColor(state, colorScheme),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: state.isCheckingPermission
                ? null
                : () => _openConnectedDevicesDialog(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.print_outlined,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDevice?.name ?? 'Pilih perangkat printer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _deviceSubtitle(state),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: state.isCheckingPermission
                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.38)
                        : colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: _canTestPrint(state)
                ? () => context.read<BluetoothBloc>().add(
                    const BluetoothTestPrintRequested(),
                  )
                : null,
            icon: state.isPrintingTest
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print_outlined),
            label: Text(state.isPrintingTest ? 'Mengirim...' : 'Test print'),
          ),
        ],
      ),
    );
  }
}

class _ConnectedDevicesDialog extends StatelessWidget {
  const _ConnectedDevicesDialog();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothBloc, BluetoothState>(
      listenWhen: (previous, current) {
        return previous.connectedDeviceSerial != current.connectedDeviceSerial;
      },
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      child: AlertDialog(
        title: Row(
          children: [
            const Expanded(child: Text('Perangkat yang terhubung')),
            IconButton(
              tooltip: 'Scan ulang',
              onPressed: context.watch<BluetoothBloc>().state.isLoadingDevices
                  ? null
                  : () => context.read<BluetoothBloc>().add(
                      const BluetoothDevicesRequested(),
                    ),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: BlocBuilder<BluetoothBloc, BluetoothState>(
            builder: (context, state) {
              if (state.isLoadingDevices && state.devices.isEmpty) {
                return const _DialogProgressMessage();
              }

              if (!state.hasBluetoothPermission) {
                return const _DialogEmptyMessage(
                  icon: Icons.bluetooth_disabled_outlined,
                  message: 'Izin Bluetooth belum diberikan.',
                );
              }

              if (state.devices.isEmpty) {
                return const _DialogEmptyMessage(
                  icon: Icons.print_disabled_outlined,
                  message: 'Tidak ada perangkat Bluetooth ditemukan.',
                );
              }

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.devices.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _BluetoothDeviceTile(
                      device: state.devices[index],
                      state: state,
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _BluetoothDeviceTile extends StatelessWidget {
  const _BluetoothDeviceTile({required this.device, required this.state});

  final BluetoothDevice device;
  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = state.selectedDevice == device;
    final isConnecting = state.connectingDeviceAddress == device.address;
    final canConnect = state.connectingDeviceAddress == null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.print_outlined),
      title: Text(device.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        device.address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isConnecting
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : TextButton(
              onPressed: canConnect ? () => _connect(context, device) : null,
              child: const Text('Connect'),
            ),
      onTap: canConnect ? () => _connect(context, device) : null,
    );
  }
}

class _DialogProgressMessage extends StatelessWidget {
  const _DialogProgressMessage();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 14),
          const Text('Memindai perangkat...'),
        ],
      ),
    );
  }
}

class _DialogEmptyMessage extends StatelessWidget {
  const _DialogEmptyMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

void _openConnectedDevicesDialog(BuildContext context) {
  final bloc = context.read<BluetoothBloc>()
    ..add(const BluetoothDevicesRequested());

  showDialog<void>(
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: bloc,
        child: const _ConnectedDevicesDialog(),
      );
    },
  );
}

void _connect(BuildContext context, BluetoothDevice device) {
  context.read<BluetoothBloc>().add(BluetoothDeviceSelected(device));
}

bool _canTestPrint(BluetoothState state) {
  return state.selectedDevice != null &&
      state.hasBluetoothPermission &&
      state.isConnected &&
      !state.isPrintingTest;
}

String _statusLabel(BluetoothState state) {
  if (state.isCheckingPermission) return 'Checking';
  if (!state.hasBluetoothPermission) return 'No permission';
  if (state.isScanning) return 'Scanning';
  if (state.isConnecting) return 'Connecting';
  if (state.isConnected) return 'Connected';
  return state.selectedDevice == null ? 'Not set' : 'Disconnected';
}

Color _statusColor(BluetoothState state, ColorScheme colorScheme) {
  if (state.isConnected) return const Color(0xff0f9f6e);
  if (state.isCheckingPermission) return const Color(0xffd97706);
  if (!state.hasBluetoothPermission) return colorScheme.error;
  if (state.isConnecting || state.isScanning) {
    return const Color(0xffd97706);
  }
  return colorScheme.onSurfaceVariant;
}

String _deviceSubtitle(BluetoothState state) {
  if (state.isCheckingPermission) return 'Memeriksa izin Bluetooth';
  if (!state.hasBluetoothPermission) return 'Izin Bluetooth belum diberikan';
  return state.selectedDevice?.address ?? 'Pilih printer Bluetooth';
}
