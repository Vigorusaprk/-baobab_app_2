import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/activity_feed_repository.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/feed_filter_chips.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/list_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../widgets/feed_item_card.dart';
import '../widgets/feed_empty_state.dart';

/// Page racine. Fournit le BLoC et route go_router vers ici.
/// une fois la table `feed_items` prête.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          FeedBloc(repository: ActivityFeedRepository())
            ..add(const LoadFeedItems()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.titleMedium!,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.small,
                  vertical: AppDimens.small,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppDimens.radius50),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          if (state is FeedLoading || state is FeedInitial) {
            return const FeedListSkeleton();
          }
          if (state is FeedError) {
            return Center(child: Text(state.message));
          }
          final loaded = state as FeedLoaded;
          final items = loaded.visibleItems;

          return Column(
            children: [
              const SizedBox(height: 12),
              FeedFilterChips(
                activeFilter: loaded.activeFilter,
                onFilterSelected: (filter) =>
                    context.read<FeedBloc>().add(FeedFilterChanged(filter)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? FeedEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return FeedItemCard(
                            item: item,
                            onTap: () => context.read<FeedBloc>().add(
                              FeedItemTapped(item),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
