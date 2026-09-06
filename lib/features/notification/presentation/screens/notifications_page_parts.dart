part of 'notifications_page.dart';

/// « Tout » ou « Non lues ». Les anciens onglets proposaient « Promotions »,
/// qui ne pouvait rien contenir : rien dans la plateforme n'écrit de
/// notification promotionnelle.
class _UnreadFilter extends StatelessWidget {
  const _UnreadFilter({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.appPaddingValue,
        vertical: AppDimens.small,
      ),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Tout'),
            selected: !state.unreadOnly,
            onSelected: (_) => cubit.toggleUnreadOnly(false),
          ),
          AppDimens.spacerSmallWidth,
          ChoiceChip(
            label: Text(
              state.unread > 0 ? 'Non lues (${state.unread})' : 'Non lues',
            ),
            selected: state.unreadOnly,
            onSelected: (_) => cubit.toggleUnreadOnly(true),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.unreadOnly});

  final bool unreadOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              unreadOnly
                  ? Icons.mark_email_read_outlined
                  : Icons.notifications_none_rounded,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.55),
            ),
            AppDimens.spacerMedium,
            Text(
              unreadOnly ? 'Tout est lu' : 'Aucune notification',
              style: theme.textTheme.bodyLarge,
            ),
            AppDimens.spacerSmall,
            Text(
              unreadOnly
                  ? 'Vous n\'avez rien en attente.'
                  : 'Le suivi de vos commandes et les nouvelles de vos '
                        'commerces apparaîtront ici.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un visiteur sans compte n'a pas de notifications : on le dit, et on
/// propose la connexion plutôt que de montrer un vide qui ressemble à une
/// panne.
class _GuestNotice extends StatelessWidget {
  const _GuestNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.55),
            ),
            AppDimens.spacerMedium,
            Text('Vos notifications', style: theme.textTheme.bodyLarge),
            AppDimens.spacerSmall,
            Text(
              'Connectez-vous pour suivre vos commandes et vos réservations.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            AppDimens.spacerLarge,
            CustomActionButton(
              label: 'Se connecter',
              icon: Icons.login_rounded,
              onPressed: () => showAuthRequiredCard(
                context,
                message: 'Connectez-vous pour voir vos notifications.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingMore extends StatelessWidget {
  const _LoadingMore();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppDimens.small),
      child: FeedListSkeleton(itemCount: 2),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 44,
              color: theme.colorScheme.error,
            ),
            AppDimens.spacerMedium,
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            AppDimens.spacerMedium,
            CustomActionButton(
              label: 'Réessayer',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
