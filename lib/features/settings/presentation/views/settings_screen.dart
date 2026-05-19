import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_theme_mode.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/models/unlock_gesture.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(size: 28, borderRadius: 8),
            SizedBox(width: 12),
            Text('Settings'),
          ],
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final cubit = context.read<SettingsCubit>();
          final settings = state.settings;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _SectionTitle(title: 'Activation delay'),
              const SizedBox(height: 8),
              Text(
                'Seconds before touch lock starts (${AppConstants.minActivationDelaySeconds}–${AppConstants.maxActivationDelaySeconds})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${settings.activationDelaySeconds} sec',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: AppConstants.delayPresets
                              .map(
                                (preset) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ActionChip(
                                    label: Text('${preset}s'),
                                    onPressed: () => cubit.setDelay(preset),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Slider(
                        value: settings.activationDelaySeconds.toDouble(),
                        min: AppConstants.minActivationDelaySeconds.toDouble(),
                        max: AppConstants.maxActivationDelaySeconds.toDouble(),
                        divisions: AppConstants.maxActivationDelaySeconds -
                            AppConstants.minActivationDelaySeconds,
                        label: '${settings.activationDelaySeconds}s',
                        onChanged: (value) =>
                            cubit.setDelay(value.round()),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Unlock gesture'),
              const SizedBox(height: 12),
              ...UnlockGesture.values.map(
                (gesture) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: RadioListTile<UnlockGesture>(
                      value: gesture,
                      groupValue: settings.unlockGesture,
                      onChanged: (value) {
                        if (value != null) cubit.setUnlockGesture(value);
                      },
                      title: Text(
                        gesture.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(gesture.description),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Theme'),
              const SizedBox(height: 12),
              SegmentedButton<AppThemeMode>(
                segments: AppThemeMode.values
                    .map(
                      (mode) => ButtonSegment(
                        value: mode,
                        label: Text(mode.label),
                        icon: Icon(switch (mode) {
                          AppThemeMode.system => Icons.brightness_auto,
                          AppThemeMode.light => Icons.light_mode,
                          AppThemeMode.dark => Icons.dark_mode,
                        }),
                      ),
                    )
                    .toList(),
                selected: {settings.themeMode},
                onSelectionChanged: (selection) {
                  cubit.setThemeMode(selection.first);
                },
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Preferences'),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Haptic feedback'),
                      subtitle: const Text('Vibrate on enable and disable'),
                      value: settings.hapticFeedback,
                      onChanged: cubit.setHaptic,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Countdown notification'),
                      subtitle: const Text(
                        'Show foreground notification during delay',
                      ),
                      value: settings.showCountdownNotification,
                      onChanged: cubit.setCountdownNotification,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
