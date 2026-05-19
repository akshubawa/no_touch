import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/services/touch_lock_platform_service.dart';
import '../features/home/presentation/cubit/activation_cubit.dart';
import '../features/home/presentation/views/home_screen.dart';
import '../features/settings/data/repositories/settings_repository.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import '../features/settings/presentation/cubit/settings_state.dart';
import 'theme/app_theme.dart';

class NoTouchApp extends StatelessWidget {
  const NoTouchApp({
    super.key,
    required this.settingsRepository,
    required this.platformService,
  });

  final SettingsRepository settingsRepository;
  final TouchLockPlatformService platformService;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: settingsRepository),
        RepositoryProvider.value(value: platformService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SettingsCubit(settingsRepository)..load(),
          ),
          BlocProvider(
            create: (_) => ActivationCubit(platformService),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (previous, current) =>
              previous.settings.themeMode != current.settings.themeMode,
          builder: (context, state) {
            final themeMode = state.settings.themeMode;

            return MaterialApp(
              title: 'No Touch',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: AppTheme.toFlutterThemeMode(themeMode),
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}
