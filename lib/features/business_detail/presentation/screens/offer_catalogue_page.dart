import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/features/business_detail/data/offer_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_catalogue_states.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_selection.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_tile.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

/// Catalogue d'un commerçant, filtré sur un mode d'acquisition.
///
/// C'est l'écran qui rend enfin fonctionnelles les catégories qui n'avaient
/// aucun parcours : cinéma, événements, spa, tourisme, voyage, services,
/// boutiques. Il ne connaît aucun métier — il affiche des offres, et selon
/// leur [Fulfilment] déclenche une commande ou une réservation.
class OfferCataloguePage extends StatefulWidget {
  final Business business;

  /// Mode d'acquisition affiché : les offres à commander, ou à réserver.
  final Fulfilment fulfilment;

  const OfferCataloguePage({
    super.key,
    required this.business,
    required this.fulfilment,
  });

  @override
  State<OfferCataloguePage> createState() => _OfferCataloguePageState();
}

class _OfferCataloguePageState extends State<OfferCataloguePage> {
  final OfferApiService _api = OfferApiService();
  final OfferSelection _selection = OfferSelection();

  BusinessCatalogue? _catalogue;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  bool get _isOrder => widget.fulfilment == Fulfilment.order;

  List<Offer> get _offers =>
      (_catalogue?.offers ?? const <Offer>[])
          .where((o) => o.fulfilment == widget.fulfilment)
          .toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final catalogue = await _api.getCatalogue(widget.business.id);
      if (!mounted) return;
      setState(() {
        _catalogue = catalogue;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selection.selectedFrom(_offers);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(_isOrder ? 'Commander' : 'Réserver'),
      ),
      body: _buildBody(),
      bottomNavigationBar: selected.isEmpty ? null : _buildFooter(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const OfferCatalogueSkeleton();

    if (_error != null) {
      return OfferCatalogueMessage(
        icon: Icons.error_outline,
        color: AppColors.error,
        text: _error!,
        actionLabel: 'Réessayer',
        onAction: _load,
      );
    }

    final offers = _offers;
    if (offers.isEmpty) {
      return OfferCatalogueMessage(
        icon: Icons.inventory_2_outlined,
        color: AppColors.textSecondary,
        text: _isOrder
            ? "Ce commerçant ne propose rien à commander pour le moment."
            : "Ce commerçant ne propose aucune réservation pour le moment.",
      );
    }

    // Regroupement par section, l'ordre venant déjà du serveur.
    final sections = <String, List<Offer>>{};
    for (final offer in offers) {
      sections.putIfAbsent(offer.section ?? 'Offres', () => []).add(offer);
    }

    return ListView(
      padding: offerListPadding,
      children: [
        Text(widget.business.name, style: Theme.of(context).textTheme.bodyLarge),
        AppDimens.spacerSmall,
        Text(
          _isOrder
              ? 'Choisissez ce que vous souhaitez commander.'
              : 'Choisissez ce que vous souhaitez réserver.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        AppDimens.spacerMedium,
        for (final entry in sections.entries) ...[
          Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
          AppDimens.spacerSmall,
          for (final offer in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OfferTile(
                offer: offer,
                quantity: _selection.quantityOf(offer),
                onQuantityChanged: (q) =>
                    setState(() => _selection.setQuantity(offer, q)),
              ),
            ),
          AppDimens.spacerMedium,
        ],
        if (!_isOrder && _selection.needsDateChoice(offers))
          OfferDatePicker(
            date: _selection.chosenDate,
            onPicked: (d) => setState(() => _selection.chosenDate = d),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    final offers = _offers;
    final blocked =
        !_isOrder &&
        _selection.needsDateChoice(offers) &&
        _selection.chosenDate == null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '${_selection.totalFor(offers).toStringAsFixed(2)} \$',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            AppDimens.spacerSmall,
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_submitting || blocked) ? null : _submit,
                child: Text(
                  _submitting
                      ? 'Envoi...'
                      : blocked
                      ? 'Choisissez une date'
                      : (_isOrder ? 'Commander' : 'Réserver'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    // Découvrir ne demande pas de compte, mais commander ou réserver oui :
    // l'opération doit être rattachée à quelqu'un.
    final user = SessionService.instance.currentUser;
    if (user == null) {
      await showAuthRequiredCard(
        context,
        message: _isOrder
            ? 'Connectez-vous pour passer votre commande.'
            : 'Connectez-vous pour confirmer votre réservation.',
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      if (_isOrder) {
        await _selection.submitOrder(
          business: widget.business,
          offers: _offers,
          userId: user.id,
        );
      } else {
        await _selection.submitBooking(
          business: widget.business,
          offers: _offers,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isOrder
                ? 'Commande envoyée. Retrouvez-la dans Mes activités.'
                : 'Réservation confirmée. Retrouvez-la dans Mes activités.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec : $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
