import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/touch_lock_platform_service.dart';
import 'features/settings/data/repositories/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(prefs);
  final platformService = TouchLockPlatformService();

  runApp(
    NoTouchApp(
      settingsRepository: settingsRepository,
      platformService: platformService,
    ),
  );
}
