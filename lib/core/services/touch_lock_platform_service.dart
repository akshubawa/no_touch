import 'dart:async';

import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../../features/settings/domain/models/unlock_gesture.dart';

enum NativeLockStatus { idle, countdown, active }

class TouchLockPlatformService {
  TouchLockPlatformService() {
    _eventChannel.receiveBroadcastStream().listen(_handleEvent);
  }

  static const _methodChannel = MethodChannel(AppConstants.channelName);
  static const _eventChannel = EventChannel(AppConstants.eventChannelName);

  final _statusController = StreamController<NativeLockStatus>.broadcast();
  final _countdownController = StreamController<int>.broadcast();

  Stream<NativeLockStatus> get statusStream => _statusController.stream;
  Stream<int> get countdownStream => _countdownController.stream;

  void _handleEvent(dynamic event) {
    if (event is! Map) return;
    final type = event['type'] as String?;
    switch (type) {
      case 'status':
        final status = event['value'] as String?;
        _statusController.add(_parseStatus(status));
      case 'countdown':
        final seconds = event['value'] as int? ?? 0;
        _countdownController.add(seconds);
    }
  }

  NativeLockStatus _parseStatus(String? value) {
    return switch (value) {
      'countdown' => NativeLockStatus.countdown,
      'active' => NativeLockStatus.active,
      _ => NativeLockStatus.idle,
    };
  }

  Future<bool> isOverlayGranted() async {
    final result = await _methodChannel.invokeMethod<bool>('isOverlayGranted');
    return result ?? false;
  }

  Future<void> openOverlaySettings() {
    return _methodChannel.invokeMethod<void>('openOverlaySettings');
  }

  Future<bool> isAccessibilityEnabled() async {
    final result =
        await _methodChannel.invokeMethod<bool>('isAccessibilityEnabled');
    return result ?? false;
  }

  Future<void> openAccessibilitySettings() {
    return _methodChannel.invokeMethod<void>('openAccessibilitySettings');
  }

  Future<NativeLockStatus> getLockStatus() async {
    final result = await _methodChannel.invokeMethod<String>('getLockStatus');
    return _parseStatus(result);
  }

  Future<void> startLock({
    required int delaySeconds,
    required UnlockGesture unlockGesture,
  }) {
    return _methodChannel.invokeMethod<void>('startLock', {
      'delaySeconds': delaySeconds,
      'unlockGesture': unlockGesture.name,
    });
  }

  Future<void> stopLock() {
    return _methodChannel.invokeMethod<void>('stopLock');
  }

  Future<void> cancelPending() {
    return _methodChannel.invokeMethod<void>('cancelPending');
  }

  void dispose() {
    _statusController.close();
    _countdownController.close();
  }
}
