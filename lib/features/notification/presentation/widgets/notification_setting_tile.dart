import 'package:baobabe_0_2/features/notification/data/notification_preferences.dart';
import 'package:baobabe_0_2/features/notification/data/push_token_service.dart';
import 'package:baobabe_0_2/features/notification/presentation/notification_prompt.dart';
import 'package:flutter/material.dart';

/// Le commutateur « Notifications » des réglages.
///
/// Il était **décoratif** : sa valeur suivait « suis-je connecté ? » et son
/// `onChanged` ne faisait rien. Un contrôle qui ne contrôle rien est pire que
/// pas de contrôle : on croit avoir coupé, et les notifications continuent.
///
/// Il a maintenant deux rôles, et c'est le second qui compte le plus :
///
/// - **dire l'état réel**, lu auprès du système et non d'un fanion local ;
/// - **rattraper un refus**. La règle du produit ne pose la question que deux
///   fois ; passé ce cap, c'est ici — et seulement ici — qu'on peut encore
///   dire oui. Sans cette porte, un refus hâtif serait définitif.
///
/// Couper, en revanche, n'est pas de notre ressort : aucune application ne
/// peut se retirer une permission qu'elle a reçue. Le geste ouvre donc les
/// réglages du téléphone, qui, eux, le peuvent.
class NotificationSettingTile extends StatefulWidget {
  const NotificationSettingTile({
    super.key,
    required this.builder,
    required this.onRequireLogin,
    required this.isLoggedIn,
  });

  /// Rend la tuile. Passer par un `builder` évite de recopier ici
  /// l'habillage de `InfoTile`, qui appartient aux réglages.
  final Widget Function(
    BuildContext context,
    Widget trailing,
    VoidCallback onTap,
  )
  builder;

  final VoidCallback onRequireLogin;
  final bool isLoggedIn;

  @override
  State<NotificationSettingTile> createState() =>
      _NotificationSettingTileState();
}

class _NotificationSettingTileState extends State<NotificationSettingTile>
    with WidgetsBindingObserver {
  bool _granted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Au retour des réglages du téléphone, l'état a pu changer sans que
  /// l'application en soit avertie : c'est le seul moyen de le savoir.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final granted = await PushTokenService.instance.isGranted();
    if (!mounted || granted == _granted) return;
    setState(() => _granted = granted);
  }

  Future<void> _toggle() async {
    if (!widget.isLoggedIn) {
      widget.onRequireLogin();
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);

    try {
      if (_granted) {
        // On ne peut pas se retirer soi-même une permission accordée.
        await NotificationPrompt.openSystemSettings();
        return;
      }

      final granted = await PushTokenService.instance.requestFromSystem();
      if (granted) {
        // Activer soi-même revient sur un refus passé : il serait absurde de
        // continuer à l'opposer aux prochaines actions.
        await NotificationPreferences.reset();
        final prefs = await NotificationPreferences.load();
        await prefs.markGranted();
      } else {
        // Le système n'a rien montré — deux refus, et il ne montre plus
        // rien. Les réglages sont la seule issue restante.
        await NotificationPrompt.openSystemSettings();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      Switch(
        // L'état vient du système, pas d'un fanion local : c'est lui qui
        // décide, et il peut changer hors de l'application.
        value: widget.isLoggedIn && _granted,
        onChanged: _busy ? null : (_) => _toggle(),
      ),
      _toggle,
    );
  }
}
