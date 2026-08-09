import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final Locale locale;
  SettingsState({required this.locale});
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState(locale: const Locale('fr', 'FR'))) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'fr';
    emit(SettingsState(locale: Locale(languageCode)));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    emit(SettingsState(locale: locale));
  }
}
