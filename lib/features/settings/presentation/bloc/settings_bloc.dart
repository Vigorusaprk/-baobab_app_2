import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  SettingsState({required this.themeMode, required this.locale});
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState(themeMode: ThemeMode.system, locale: const Locale('fr', 'FR'))) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    final languageCode = prefs.getString('language_code') ?? 'fr';
    emit(SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      locale: Locale(languageCode),
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    emit(SettingsState(themeMode: mode, locale: state.locale));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    emit(SettingsState(themeMode: state.themeMode, locale: locale));
  }
}