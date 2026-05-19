import 'package:equatable/equatable.dart';

import '../../../../core/services/touch_lock_platform_service.dart';

class ActivationState extends Equatable {
  const ActivationState({
    this.lockStatus = NativeLockStatus.idle,
    this.countdownSeconds = 0,
    this.overlayGranted = false,
    this.accessibilityEnabled = false,
    this.isCheckingPermissions = true,
    this.errorMessage,
  });

  final NativeLockStatus lockStatus;
  final int countdownSeconds;
  final bool overlayGranted;
  final bool accessibilityEnabled;
  final bool isCheckingPermissions;
  final String? errorMessage;

  bool get isLocked => lockStatus == NativeLockStatus.active;
  bool get isCountingDown => lockStatus == NativeLockStatus.countdown;
  bool get canActivate =>
      overlayGranted && !isLocked && !isCountingDown;

  bool get permissionsReady => overlayGranted;

  ActivationState copyWith({
    NativeLockStatus? lockStatus,
    int? countdownSeconds,
    bool? overlayGranted,
    bool? accessibilityEnabled,
    bool? isCheckingPermissions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActivationState(
      lockStatus: lockStatus ?? this.lockStatus,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      overlayGranted: overlayGranted ?? this.overlayGranted,
      accessibilityEnabled:
          accessibilityEnabled ?? this.accessibilityEnabled,
      isCheckingPermissions:
          isCheckingPermissions ?? this.isCheckingPermissions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        lockStatus,
        countdownSeconds,
        overlayGranted,
        accessibilityEnabled,
        isCheckingPermissions,
        errorMessage,
      ];
}
