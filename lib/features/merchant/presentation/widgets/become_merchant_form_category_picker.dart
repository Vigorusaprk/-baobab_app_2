part of 'become_merchant_sheet.dart';

/// Les catégories proposées viennent du serveur, comme celles de l'accueil :
/// un commerçant ne doit jamais pouvoir se ranger dans une catégorie que
/// l'application ne sait pas afficher.
class _CategoryPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const _CategoryPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = state is CategoriesLoaded
            ? state.categories
                  .where((c) => c.slug != Category.all.slug)
                  .toList()
            : const <Category>[];

        if (categories.isEmpty) {
          return Text(
            'Chargement des catégories…',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }

        return Wrap(
          spacing: AppDimens.small,
          runSpacing: AppDimens.small,
          children: categories.map((category) {
            final isSelected = category.slug == selected;
            return ChoiceChip(
              label: Text(category.displayName),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              onSelected: (_) => onChanged(category.slug),
            );
          }).toList(),
        );
      },
    );
  }
}
