import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/theme/app_theme_mode.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/unlock_gesture.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _delayKey = 'activation_delay_seconds';
  static const _gestureKey = 'unlock_gesture';
  static const _themeKey = 'theme_mode';
  static const _hapticKey = 'haptic_feedback';
  static const _notificationKey = 'show_countdown_notification';

  AppSettings load() {
    return AppSettings(
      activationDelaySeconds: _prefs.getInt(_delayKey) ?? 10,
      unlockGesture: unlockGestureFromName(_prefs.getString(_gestureKey)),
      themeMode: appThemeModeFromName(_prefs.getString(_themeKey)),
      hapticFeedback: _prefs.getBool(_hapticKey) ?? true,
      showCountdownNotification: _prefs.getBool(_notificationKey) ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setInt(_delayKey, settings.activationDelaySeconds);
    await _prefs.setString(_gestureKey, settings.unlockGesture.name);
    await _prefs.setString(_themeKey, settings.themeMode.name);
    await _prefs.setBool(_hapticKey, settings.hapticFeedback);
    await _prefs.setBool(
      _notificationKey,
      settings.showCountdownNotification,
    );
  }
}
