import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Les deux éléments de formulaire propres à l'espace commerçant : le
/// libellé au-dessus d'un champ, et le choix d'une date imposée.

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: AppDimens.small),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

/// Choix d'une date imposée, avec de quoi revenir en arrière : une offre
/// dont le client choisit lui-même le créneau ne doit pas en porter une.
class DateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const DateField({
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
        onTap: onPick,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              AppDimens.spacerMediumWidth,
              Expanded(
                child: Text(
                  value == null
                      ? 'Le client choisit sa date'
                      : DateFormat('dd/MM/yyyy à HH:mm').format(value!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (value != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClear,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
