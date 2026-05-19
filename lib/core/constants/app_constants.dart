abstract final class AppConstants {
  static const String channelName =
      'app.significantinfotech.notouch/touch_lock';
  static const String eventChannelName =
      'app.significantinfotech.notouch/touch_lock_events';

  static const int minActivationDelaySeconds = 3;
  static const int maxActivationDelaySeconds = 60;
  static const int defaultActivationDelaySeconds = 10;

  static const List<int> delayPresets = [5, 10, 15, 30, 60];
}
