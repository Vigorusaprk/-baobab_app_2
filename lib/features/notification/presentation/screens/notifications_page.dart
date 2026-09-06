import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/list_skeletons.dart';
import 'package:baobabe_0_2/features/notification/domain/entities/app_notification.dart';
import 'package:baobabe_0_2/features/notification/presentation/cubit/notifications_cubit.dart';
import 'package:baobabe_0_2/features/notification/presentation/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'notifications_page_parts.dart';

/// Le fil des notifications.
///
/// Il lit désormais la table `notifications`, seul passage de tout ce que la
/// plateforme annonce. Avant, l'écran refabriquait ses lignes à partir des
/// commandes et des réservations du client : il ne pouvait montrer ni un
/// avis reçu, ni une mise en avant validée, ni rien du côté commerçant, et
/// « lu » s'oubliait à la fermeture de l'application.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  /// Le cubit vient de l'application, pas de l'écran : la pastille de
  /// l'accueil lit le même compte, et un second exemplaire les aurait fait
  /// diverger.
  @override
  Widget build(BuildContext context) => const _NotificationsView();
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // On relit en arrivant : la liste peut avoir vieilli depuis le
    // lancement de l'application. Ici et non dans `build`, qui se rejoue à
    // chaque émission du cubit — et rappellerait donc sans fin.
    context.read<NotificationsCubit>().load();
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// La vue prévient seulement qu'on approche de la fin ; le cubit décide
  /// s'il y a une page suivante.
  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      context.read<NotificationsCubit>().loadMore();
    }
  }

  Future<void> _open(AppNotification notification) async {
    final cubit = context.read<NotificationsCubit>();
    await cubit.markRead(notification);
    if (!mounted) return;

    final route = notification.route;
    if (route == null || route.isEmpty) return;
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomOtherAppBar(
        title: 'Notifications',
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            buildWhen: (previous, current) => previous.unread != current.unread,
            builder: (context, state) {
              // Le bouton n'apparaît que s'il y a quelque chose à marquer :
              // « tout marquer comme lu » sur un fil déjà lu ne fait rien et
              // laisse croire qu'on a raté quelque chose.
              if (state.unread == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () =>
                    context.read<NotificationsCubit>().markAllRead(),
                child: const Text('Tout lire'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.isGuest) return const _GuestNotice();
          if (state.isLoading) return const FeedListSkeleton();
          if (state.error != null && state.items.isEmpty) {
            return _Failure(
              message: state.error!,
              onRetry: () => context.read<NotificationsCubit>().load(),
            );
          }

          return CustomRefresh(
            onRefresh: () => context.read<NotificationsCubit>().load(),
            child: Column(
              children: [
                _UnreadFilter(state: state),
                Expanded(
                  child: state.items.isEmpty
                      ? _Empty(unreadOnly: state.unreadOnly)
                      : ListView.separated(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(
                            AppDimens.appPaddingValue,
                            0,
                            AppDimens.appPaddingValue,
                            AppDimens.large,
                          ),
                          itemCount:
                              state.items.length +
                              (state.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, _) => AppDimens.spacerSmall,
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const _LoadingMore();
                            }
                            final notification = state.items[index];
                            return NotificationTile(
                              notification: notification,
                              onTap: () => _open(notification),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
