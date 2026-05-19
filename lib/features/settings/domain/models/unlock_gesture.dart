enum UnlockGesture {
  tripleTap,
  longPress,
  volumeKeys,
}

extension UnlockGestureX on UnlockGesture {
  String get label => switch (this) {
        UnlockGesture.tripleTap => 'Triple tap icon',
        UnlockGesture.longPress => 'Long press 3 seconds',
        UnlockGesture.volumeKeys => 'Volume Up + Down',
      };

  String get description => switch (this) {
        UnlockGesture.tripleTap =>
          'Tap the floating shield three times quickly.',
        UnlockGesture.longPress =>
          'Press and hold the floating shield for 3 seconds.',
        UnlockGesture.volumeKeys =>
          'Press Volume Up and Volume Down together while locked.',
      };

}

UnlockGesture unlockGestureFromName(String? name) {
  return UnlockGesture.values.firstWhere(
    (g) => g.name == name,
    orElse: () => UnlockGesture.tripleTap,
  );
}
