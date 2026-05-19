import 'package:equatable/equatable.dart';

import '../../domain/models/app_settings.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.isSaving = false,
  });

  const SettingsState.initial()
      : this(settings: const AppSettings(), isLoading: true);

  final AppSettings settings;
  final bool isLoading;
  final bool isSaving;

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    bool? isSaving,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading, isSaving];
}
