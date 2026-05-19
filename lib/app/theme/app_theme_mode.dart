enum AppThemeMode {
  system,
  light,
  dark,
}

extension AppThemeModeX on AppThemeMode {
  String get label => switch (this) {
        AppThemeMode.system => 'System',
        AppThemeMode.light => 'Light',
        AppThemeMode.dark => 'Dark',
      };

}

AppThemeMode appThemeModeFromName(String? name) {
  return AppThemeMode.values.firstWhere(
    (m) => m.name == name,
    orElse: () => AppThemeMode.system,
  );
}
