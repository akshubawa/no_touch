import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_theme_mode.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/unlock_gesture.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState.initial());

  final SettingsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final settings = _repository.load();
    emit(state.copyWith(isLoading: false, settings: settings));
  }

  Future<void> setDelay(int seconds) async {
    final updated = state.settings.copyWith(activationDelaySeconds: seconds);
    await _persist(updated);
  }

  Future<void> setUnlockGesture(UnlockGesture gesture) async {
    final updated = state.settings.copyWith(unlockGesture: gesture);
    await _persist(updated);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final updated = state.settings.copyWith(themeMode: mode);
    await _persist(updated);
  }

  Future<void> setHaptic(bool enabled) async {
    final updated = state.settings.copyWith(hapticFeedback: enabled);
    await _persist(updated);
  }

  Future<void> setCountdownNotification(bool enabled) async {
    final updated =
        state.settings.copyWith(showCountdownNotification: enabled);
    await _persist(updated);
  }

  Future<void> _persist(AppSettings settings) async {
    emit(state.copyWith(settings: settings, isSaving: true));
    await _repository.save(settings);
    emit(state.copyWith(isSaving: false));
  }
}
