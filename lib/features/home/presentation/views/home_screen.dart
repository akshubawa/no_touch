import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/permission_tile.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../settings/domain/models/unlock_gesture.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../cubit/activation_cubit.dart';
import '../../domain/models/activation_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<ActivationCubit>().initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ActivationCubit>().refreshPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(size: 32, borderRadius: 8),
            SizedBox(width: 12),
            Text('No Touch'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ActivationCubit, ActivationState>(
          builder: (context, activation) {
            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<ActivationCubit>().refreshPermissions(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    children: [
                      _HeroHeader(activation: activation),
                      const SizedBox(height: 20),
                      _StatusSection(activation: activation),
                      const SizedBox(height: 20),
                      _PermissionsSection(activation: activation),
                      const SizedBox(height: 24),
                      _ActivationCard(
                        activation: activation,
                        delaySeconds:
                            settingsState.settings.activationDelaySeconds,
                        unlockLabel:
                            settingsState.settings.unlockGesture.label,
                      ),
                      if (activation.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          activation.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.activation});

  final ActivationState activation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(size: 72, borderRadius: 18),
        const SizedBox(height: 16),
        Text(
          'Kid-safe touch lock',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Block accidental taps while watching videos or using kids apps. '
          'A floating shield unlocks touch only after your chosen gesture.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.activation});

  final ActivationState activation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (activation.isLocked) {
      return StatusBanner(
        icon: Icons.lock_rounded,
        title: 'Touch is locked',
        subtitle: 'Use the floating shield and your unlock gesture to release.',
        color: colorScheme.primary,
      );
    }

    if (activation.isCountingDown) {
      return StatusBanner(
        icon: Icons.hourglass_top_rounded,
        title: 'Activating in ${activation.countdownSeconds}s',
        subtitle:
            'Switch to the app you want — touch lock starts when the timer ends.',
        color: colorScheme.tertiary,
      );
    }

    return StatusBanner(
      icon: Icons.touch_app_outlined,
      title: 'Touch is unlocked',
      subtitle: 'Tap Enable below after granting overlay permission.',
      color: colorScheme.outline,
    );
  }
}

class _PermissionsSection extends StatelessWidget {
  const _PermissionsSection({required this.activation});

  final ActivationState activation;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ActivationCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permissions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        PermissionTile(
          title: 'Display over other apps',
          subtitle: 'Required to block touches system-wide.',
          isGranted: activation.overlayGranted,
          onTap: cubit.openOverlaySettings,
        ),
        const SizedBox(height: 10),
        PermissionTile(
          title: 'Accessibility service',
          subtitle:
              'Keeps the lock reliable, detects foreground apps, and enables volume-key unlock.',
          isGranted: activation.accessibilityEnabled,
          recommended: true,
          onTap: cubit.openAccessibilitySettings,
        ),
      ],
    );
  }
}

class _ActivationCard extends StatelessWidget {
  const _ActivationCard({
    required this.activation,
    required this.delaySeconds,
    required this.unlockLabel,
  });

  final ActivationState activation;
  final int delaySeconds;
  final String unlockLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<ActivationCubit>();
    final settings = context.read<SettingsCubit>().state.settings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Activation',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Touch lock starts after $delaySeconds seconds so you can open your target app.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Unlock: $unlockLabel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            if (activation.isCountingDown || activation.isLocked) ...[
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  cubit.cancel();
                },
                icon: const Icon(Icons.close_rounded),
                label: Text(
                  activation.isLocked ? 'Disable touch lock' : 'Cancel countdown',
                ),
              ),
            ] else
              FilledButton.icon(
                onPressed: activation.canActivate
                    ? () async {
                        if (settings.hapticFeedback) {
                          HapticFeedback.mediumImpact();
                        }
                        await cubit.activate(settings);
                      }
                    : null,
                icon: const Icon(Icons.shield_outlined),
                label: const Text('Enable touch lock'),
              ),
            if (!activation.overlayGranted) ...[
              const SizedBox(height: 12),
              Text(
                'Grant overlay permission above to enable.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
