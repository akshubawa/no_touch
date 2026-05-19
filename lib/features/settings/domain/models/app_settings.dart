import 'package:equatable/equatable.dart';

import '../../../../app/theme/app_theme_mode.dart';
import 'unlock_gesture.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.activationDelaySeconds = 10,
    this.unlockGesture = UnlockGesture.tripleTap,
    this.themeMode = AppThemeMode.system,
    this.hapticFeedback = true,
    this.showCountdownNotification = true,
  });

  final int activationDelaySeconds;
  final UnlockGesture unlockGesture;
  final AppThemeMode themeMode;
  final bool hapticFeedback;
  final bool showCountdownNotification;

  AppSettings copyWith({
    int? activationDelaySeconds,
    UnlockGesture? unlockGesture,
    AppThemeMode? themeMode,
    bool? hapticFeedback,
    bool? showCountdownNotification,
  }) {
    return AppSettings(
      activationDelaySeconds:
          activationDelaySeconds ?? this.activationDelaySeconds,
      unlockGesture: unlockGesture ?? this.unlockGesture,
      themeMode: themeMode ?? this.themeMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      showCountdownNotification:
          showCountdownNotification ?? this.showCountdownNotification,
    );
  }

  @override
  List<Object?> get props => [
        activationDelaySeconds,
        unlockGesture,
        themeMode,
        hapticFeedback,
        showCountdownNotification,
      ];
}
