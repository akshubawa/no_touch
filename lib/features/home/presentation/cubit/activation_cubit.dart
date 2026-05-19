import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/touch_lock_platform_service.dart';
import '../../../settings/domain/models/app_settings.dart';
import '../../domain/models/activation_state.dart';

class ActivationCubit extends Cubit<ActivationState> {
  ActivationCubit(this._platform) : super(const ActivationState()) {
    _statusSub = _platform.statusStream.listen(_onStatus);
    _countdownSub = _platform.countdownStream.listen(_onCountdown);
  }

  final TouchLockPlatformService _platform;
  StreamSubscription<NativeLockStatus>? _statusSub;
  StreamSubscription<int>? _countdownSub;

  Future<void> initialize() async {
    await refreshPermissions();
    final status = await _platform.getLockStatus();
    emit(state.copyWith(lockStatus: status));
  }

  Future<void> refreshPermissions() async {
    emit(state.copyWith(isCheckingPermissions: true, clearError: true));
    final overlay = await _platform.isOverlayGranted();
    final accessibility = await _platform.isAccessibilityEnabled();
    emit(
      state.copyWith(
        overlayGranted: overlay,
        accessibilityEnabled: accessibility,
        isCheckingPermissions: false,
      ),
    );
  }

  Future<void> openOverlaySettings() => _platform.openOverlaySettings();

  Future<void> openAccessibilitySettings() =>
      _platform.openAccessibilitySettings();

  Future<void> activate(AppSettings settings) async {
    if (!state.overlayGranted) {
      emit(
        state.copyWith(
          errorMessage:
              'Grant "Display over other apps" before enabling touch lock.',
        ),
      );
      return;
    }

    emit(state.copyWith(clearError: true));
    try {
      await _platform.startLock(
        delaySeconds: settings.activationDelaySeconds,
        unlockGesture: settings.unlockGesture,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not start touch lock: $e'));
    }
  }

  Future<void> cancel() async {
    await _platform.cancelPending();
    await _platform.stopLock();
    emit(
      state.copyWith(
        lockStatus: NativeLockStatus.idle,
        countdownSeconds: 0,
        clearError: true,
      ),
    );
  }

  Future<void> stopLock() async {
    await _platform.stopLock();
    emit(
      state.copyWith(
        lockStatus: NativeLockStatus.idle,
        countdownSeconds: 0,
      ),
    );
  }

  void _onStatus(NativeLockStatus status) {
    emit(state.copyWith(lockStatus: status));
  }

  void _onCountdown(int seconds) {
    emit(state.copyWith(countdownSeconds: seconds));
  }

  @override
  Future<void> close() {
    _statusSub?.cancel();
    _countdownSub?.cancel();
    return super.close();
  }
}
