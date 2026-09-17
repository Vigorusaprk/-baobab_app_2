part of 'business_card.dart';

/// La tuile : la photo prend le haut, le texte le bas, sur l'aplat de la
/// carte. Pas de fondu entre les deux — voir [OfferCard], même parti, même
/// raison : la frontière n'a pas besoin d'être adoucie, et chaque version
/// essayée coûtait de la hauteur de photo.
class _Tile extends StatelessWidget {
  const _Tile({required this.business, this.featuredOffer});

  final Business business;
  final String? featuredOffer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: BusinessCard.tileAspectRatio,
          child: _Photo(business: business),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimens.allPadding12Number),
          child: _Content(business: business, featuredOffer: featuredOffer),
        ),
      ],
    );
  }
}

/// La ligne : vignette carrée à gauche, texte à droite. Même contenu que la
/// tuile, en moins haut.
class _RowLayout extends StatelessWidget {
  const _RowLayout({required this.business, this.featuredOffer});

  final Business business;
  final String? featuredOffer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.allPadding12Number),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            child: SizedBox.square(
              dimension: BusinessCard.rowThumb,
              child: _Photo(business: business, compact: true),
            ),
          ),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: _Content(business: business, featuredOffer: featuredOffer),
          ),
        ],
      ),
    );
  }
}

/// La photo de couverture, et ce qu'on pose dessus.
///
/// En repli — pas de photo, ou une photo qui ne charge pas — la tuile colorée
/// à l'initiale que l'ancienne ligne montrait *toujours*. Elle devient
/// l'exception, pas la règle : un commerce a une photo.
class _Photo extends StatelessWidget {
  const _Photo({required this.business, this.compact = false});

  final Business business;

  /// La vignette d'une ligne : trop petite pour une étiquette.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ui = UIBusiness(business);
    final fallback = _Initial(
      business: business,
      color: ui.categoryColor(context),
    );
    final url = business.bgImg.trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        url.isEmpty ? fallback : RemoteImage(url: url, fallback: fallback),
        if (!compact && ui.isNew)
          Positioned(
            top: AppDimens.small,
            left: AppDimens.small,
            child: _Badge(
              label: 'Nouveau',
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.business, required this.color});

  final Business business;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final initial = business.name.trim().isEmpty
        ? '?'
        : business.name.trim()[0].toUpperCase();

    return ColoredBox(
      color: color,
      child: Center(
        child: Text(
          initial,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Le texte : nom, puis catégorie et commune, puis la note et l'ouverture,
/// puis ce qu'on peut y faire. Chaque ligne répond à une question, dans
/// l'ordre où on se les pose.
class _Content extends StatelessWidget {
  const _Content({required this.business, this.featuredOffer});

  final Business business;
  final String? featuredOffer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = _categoryLabel(context);
    final commune = business.commune?.trim();
    final where = commune == null || commune.isEmpty
        ? label
        : '$label · $commune';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          business.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          where,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        // Ce qu'une campagne pousse. Une ligne, avant l'état : c'est la
        // raison pour laquelle ce commerce est là.
        if (featuredOffer != null && featuredOffer!.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            'Met en avant : ${featuredOffer!.trim()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        AppDimens.spacerMini,
        _StatusLine(business: business),
        if (business.canOrder || business.canBook || business.hasInStore) ...[
          AppDimens.spacerSmall,
          _Capabilities(business: business),
        ],
      ],
    );
  }

  /// Le nom de la catégorie, d'après la table `categories` quand elle est
  /// chargée. L'énumération ne connaît pas « cosmetics », « service » ni
  /// « event » et les nommait tous « Commerce » ; la table, elle, les
  /// connaît. Hors de l'application — un test, un aperçu — on retombe sur
  /// l'énumération plutôt que d'exiger un bloc.
  String _categoryLabel(BuildContext context) {
    final fallback = UIBusiness(business).categoryLabel;
    final slug = business.categorySlug;
    if (slug.isEmpty) return fallback;
    try {
      final state = context.read<CategoryBloc>().state;
      if (state is CategoriesLoaded) {
        for (final category in state.categories) {
          if (category.slug == slug) return category.displayName;
        }
      }
    } on ProviderNotFoundException {
      // Pas de bloc dans l'arbre : l'énumération suffit.
    }
    return fallback;
  }
}
