import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/notification/domain/entities/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Une notification dans le fil.
///
/// Le non-lu se voit à deux signes qui ne dépendent pas de la couleur seule :
/// le titre est en gras, et une pastille pleine borde la ligne. Un fond
/// légèrement différent ne suffit pas — sur un écran au soleil de Kinshasa,
/// il ne se voit pas.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unread = !notification.isRead;

    return Material(
      color: unread ? scheme.surfaceContainerLowest : scheme.surface,
      borderRadius: BorderRadius.circular(AppDimens.radius16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.medium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            border: Border.all(
              color: unread ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                notification.kind.icon,
                size: AppDimens.medium + 6,
                color: unread ? scheme.primary : scheme.onSurfaceVariant,
              ),
              AppDimens.spacerMediumWidth,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        AppDimens.spacerSmallWidth,
                        Text(
                          _age(notification.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    AppDimens.spacerMini,
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    if (notification.route != null &&
                        notification.kind.actionLabel != null) ...[
                      AppDimens.spacerSmall,
                      Text(
                        notification.kind.actionLabel!,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// L'âge plutôt que la date : « il y a 5 min » se lit sans calcul, et
  /// c'est la seule chose qui compte sur une notification récente. Au-delà
  /// d'une semaine, la date redevient plus parlante.
  static String _age(DateTime moment) {
    final elapsed = DateTime.now().difference(moment);
    if (elapsed.inMinutes < 1) return 'à l\'instant';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} min';
    if (elapsed.inHours < 24) return '${elapsed.inHours} h';
    if (elapsed.inDays < 7) return '${elapsed.inDays} j';
    return DateFormat('d MMM', 'fr_FR').format(moment);
  }
}
