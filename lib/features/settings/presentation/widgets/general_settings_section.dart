import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/core/widgets/custom_divider.dart';
import 'package:baobabe_0_2/features/notification/presentation/widgets/notification_setting_tile.dart';
import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/language_picker_dialog.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// La section « Générale » des paramètres : les notifications et la langue.
class GeneralSettingsSection extends StatelessWidget {
  const GeneralSettingsSection({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) => DetailSection(
        sectionTitle: 'Générale',
        children: [
          NotificationSettingTile(
            isLoggedIn: isLoggedIn,
            onRequireLogin: () => showAuthRequiredCard(
              context,
              message: 'Connectez-vous pour activer les notifications.',
            ),
            builder: (context, trailing, onTap) => InfoTile(
              subtitle: 'Notifications',
              icon: Icons.notifications_none_outlined,
              onTap: onTap,
              trailing: trailing,
            ),
          ),
          const CustomDivider(),
          InfoTile(
            subtitle: 'Langue',
            icon: Icons.language_outlined,
            onTap: () => showLanguagePickerDialog(context),
            trailing: Text(
              _languageName(settingsState.locale.languageCode),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _languageName(String code) => switch (code) {
    'fr' => 'Français',
    'en' => 'English',
    'ln' => 'Lingala',
    _ => 'Français',
  };
}
