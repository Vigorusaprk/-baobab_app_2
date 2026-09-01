import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Où en est la saisie d'un code.
enum OtpStatus {
  /// On tape. Les cases sont neutres, celle du curseur est soulignée.
  editing,

  /// Le serveur a refusé le code. Les cases passent au rouge.
  invalid,

  /// Le code est bon. Les cases passent au vert, le temps de la bascule.
  verified,
}

/// Le champ d'un code à usage unique : une case par chiffre.
///
/// Il vit dans `core/widgets` parce qu'un code se saisit partout de la même
/// façon — connexion aujourd'hui, confirmation d'une opération demain — et
/// que les détails qui le rendent utilisable ne se réécrivent pas deux fois
/// sans divergence : passer à la case suivante en tapant, revenir à la
/// précédente en effaçant, accepter un code collé d'un bloc, et rendre
/// visible ce que le serveur en a dit.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    this.length = 6,
    this.status = OtpStatus.editing,
    this.enabled = true,
    this.autofocus = true,
    this.onCompleted,
  });

  /// Reçoit le code assemblé, chiffre après chiffre.
  final TextEditingController controller;

  final int length;
  final OtpStatus status;
  final bool enabled;
  final bool autofocus;

  /// Appelé dès que la dernière case est remplie.
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late List<TextEditingController> _digits;
  late List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _digits = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());

    final existing = widget.controller.text;
    for (var i = 0; i < widget.length && i < existing.length; i++) {
      _digits[i].text = existing[i];
    }
  }

  @override
  void dispose() {
    for (final c in _digits) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _publish() {
    final code = _digits.map((c) => c.text).join();
    widget.controller.text = code;
    setState(() {});
    if (code.length == widget.length) widget.onCompleted?.call(code);
  }

  void _onChanged(int index, String value) {
    // Un code collé — ou rempli par le gestionnaire de mots de passe —
    // arrive entier dans une seule case.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _digits[i].text = i < digits.length ? digits[i] : '';
      }
      if (digits.length >= widget.length) {
        _nodes[widget.length - 1].unfocus();
      } else {
        _nodes[digits.length.clamp(0, widget.length - 1)].requestFocus();
      }
      _publish();
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    _publish();
  }

  /// Effacer sur une case vide remonte d'un cran : sans cela, corriger le
  /// troisième chiffre oblige à viser sa case au doigt.
  void _onBackspace(int index) {
    if (_digits[index].text.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
      _digits[index - 1].clear();
      _publish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => Flexible(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == widget.length - 1 ? 0 : AppDimens.small,
            ),
            child: _DigitBox(
              controller: _digits[index],
              node: _nodes[index],
              status: widget.status,
              enabled: widget.enabled,
              autofocus: widget.autofocus && index == 0,
              length: widget.length,
              onChanged: (value) => _onChanged(index, value),
              onBackspace: () => _onBackspace(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.controller,
    required this.node,
    required this.status,
    required this.enabled,
    required this.autofocus,
    required this.length,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode node;
  final OtpStatus status;
  final bool enabled;
  final bool autofocus;
  final int length;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final other = OtherTheme.of(context);

    // Le fond dit l'état du code, la bordure dit lequel des chiffres reçoit
    // la frappe. Les deux ensemble : on voit d'un coup d'œil où l'on en est
    // et ce que le serveur a répondu.
    final (fill, border, ink) = switch (status) {
      OtpStatus.invalid => (
        scheme.errorContainer,
        scheme.error,
        scheme.onErrorContainer,
      ),
      OtpStatus.verified => (
        other.successContainer,
        other.success,
        other.onSuccessContainer,
      ),
      OtpStatus.editing => (
        scheme.surfaceContainerLowest,
        scheme.outlineVariant,
        scheme.onSurface,
      ),
    };

    OutlineInputBorder side(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      borderSide: BorderSide(color: color, width: width),
    );

    return AspectRatio(
      // Des cases carrées-ish qui se partagent la largeur : six largeurs
      // fixes débordent sur un petit téléphone.
      aspectRatio: 0.82,
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.quick),
        curve: AppMotion.standard,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
        ),
        child: Focus(
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              onBackspace();
            }
            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: controller,
            focusNode: node,
            enabled: enabled,
            autofocus: autofocus,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // Autorise le collage d'un code entier dans une seule case.
            maxLength: length,
            cursorColor: scheme.primary,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: ink,
            ),
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              contentPadding: EdgeInsets.zero,
              filled: false,
              border: side(border, AppDimens.borderWidthThin),
              enabledBorder: side(border, AppDimens.borderWidthThin),
              disabledBorder: side(border, AppDimens.borderWidthThin),
              focusedBorder: side(
                status == OtpStatus.editing ? scheme.primary : border,
                2,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
