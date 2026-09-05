import 'package:baobabe_0_2/core/services/media_upload_service.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/custom_loading.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Le champ par lequel une photo entre dans l'application.
///
/// Le formulaire d'offre et la fiche du commerce demandaient une **URL** :
/// autant dire à un commerçant de Matonge d'héberger ses images lui-même. Ici
/// il prend la photo ou la choisit dans sa galerie, et l'application s'occupe
/// du reste.
///
/// Le champ montre **la photo**, pas son adresse : c'est la seule chose qui
/// dit si l'on a envoyé la bonne.
class ImageUploadField extends StatefulWidget {
  const ImageUploadField({
    super.key,
    required this.businessId,
    required this.kind,
    required this.value,
    required this.onChanged,
    this.label = 'Photo',
    this.hint,
    this.height = 168,
    this.service,
  });

  final String businessId;
  final MediaKind kind;

  /// L'URL actuelle, ou `null`.
  final String? value;

  final ValueChanged<String?> onChanged;
  final String label;
  final String? hint;
  final double height;

  /// Injectable pour les tests : sans cela, le champ ne se pose pas sans un
  /// Supabase initialisé.
  final MediaUploadService? service;

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  late final MediaUploadService _service =
      widget.service ?? MediaUploadService();

  bool _busy = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final url = await _service.pickAndUpload(
        businessId: widget.businessId,
        kind: widget.kind,
        source: source,
      );
      // `null` : la feuille de sélection a été refermée sans choisir. Ce
      // n'est pas une erreur, et rien ne doit changer.
      if (url != null) widget.onChanged(url);
    } catch (e) {
      // Le message du serveur est déjà rédigé (taille, type refusé) : le
      // remplacer par « une erreur est survenue » ferait perdre la seule
      // indication utile.
      setState(() => _error = _readable(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _remove() async {
    final current = widget.value;
    if (current == null) return;
    setState(() => _busy = true);
    await _service.remove(current);
    widget.onChanged(null);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _openChoices() async {
    final theme = Theme.of(context);

    await showCustomBottomSheet<void>(
      context: context,
      title: widget.label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Choice(
            icon: Icons.photo_camera_outlined,
            label: 'Prendre une photo',
            onTap: () {
              Navigator.of(context).pop();
              _pick(ImageSource.camera);
            },
          ),
          _Choice(
            icon: Icons.photo_library_outlined,
            label: 'Choisir dans la galerie',
            onTap: () {
              Navigator.of(context).pop();
              _pick(ImageSource.gallery);
            },
          ),
          if (widget.value != null)
            _Choice(
              icon: Icons.delete_outline_rounded,
              label: 'Retirer la photo',
              tint: theme.colorScheme.error,
              onTap: () {
                Navigator.of(context).pop();
                _remove();
              },
            ),
        ],
      ),
    );
  }

  static String _readable(Object error) {
    final text = error.toString();
    return text.length > 160 ? 'Photo refusée par le serveur.' : text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final url = widget.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 1.1,
          ),
        ),
        AppDimens.spacerSmall,
        Material(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          child: InkWell(
            onTap: _busy ? null : _openChoices,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (url != null && url.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                      child: RemoteImage(
                        url: url,
                        fallback: const _Empty(),
                      ),
                    )
                  else
                    const _Empty(),
                  if (_busy)
                    ColoredBox(
                      color: scheme.scrim.withValues(alpha: 0.35),
                      child: Center(
                        child: CustomLoadingButton(color: scheme.onPrimary),
                      ),
                    )
                  else
                    // Le geste se voit : une photo sur laquelle on peut
                    // appuyer ne le dit pas d'elle-même.
                    Positioned(
                      right: AppDimens.small,
                      bottom: AppDimens.small,
                      child: CustomActionButton(
                        label: url == null ? 'Ajouter' : 'Remplacer',
                        icon: Icons.photo_camera_outlined,
                        tone: url == null
                            ? ActionButtonTone.filled
                            : ActionButtonTone.tonal,
                        onPressed: _openChoices,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.hint != null) ...[
          AppDimens.spacerMini,
          Text(
            widget.hint!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (_error != null) ...[
          AppDimens.spacerSmall,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: AppDimens.medium,
                color: scheme.error,
              ),
              AppDimens.spacerSmallWidth,
              Expanded(
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Le cadre vide : ce qu'on voit avant d'avoir choisi.
class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: AppDimens.large + 4,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tint ?? theme.colorScheme.primary;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: tint,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
