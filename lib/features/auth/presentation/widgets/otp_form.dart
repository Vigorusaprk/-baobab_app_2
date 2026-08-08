import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpForm extends StatefulWidget {
  final VoidCallback submit;
  final TextEditingController otp;
  final String email;
  final bool isLoading;

  const OtpForm({
    super.key,
    required this.submit,
    required this.otp,
    required this.email,
    this.isLoading = false,
  });

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  static const int _length = 6;

  late final List<TextEditingController> _digitControllers;
  late final List<FocusNode> _focusNodes;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _digitControllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) => FocusNode());

    final existing = widget.otp.text;
    for (var i = 0; i < _length && i < existing.length; i++) {
      _digitControllers[i].text = existing[i];
    }
    _isComplete = _digitControllers.every((c) => c.text.isNotEmpty);
  }

  @override
  void dispose() {
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncOtpController() {
    widget.otp.text = _digitControllers.map((c) => c.text).join();
    setState(() {
      _isComplete = _digitControllers.every((c) => c.text.isNotEmpty);
    });
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // A full code was pasted/autofilled into a single box.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _length; i++) {
        _digitControllers[i].text = i < digits.length ? digits[i] : '';
      }
      final nextEmpty = digits.length.clamp(0, _length - 1);
      if (digits.length >= _length) {
        _focusNodes[_length - 1].unfocus();
      } else {
        _focusNodes[nextEmpty].requestFocus();
      }
      _syncOtpController();
      return;
    }

    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _syncOtpController();
  }

  void _onBackspace(int index) {
    if (_digitControllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _digitControllers[index - 1].clear();
      _syncOtpController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Entrez le code reçu',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Envoyé à ${widget.email}',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        AppDimens.spacerMedium,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_length, (index) {
            return SizedBox(
              width: 46,
              height: 56,
              child: Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    _onBackspace(index);
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _digitControllers[index],
                  focusNode: _focusNodes[index],
                  enabled: !widget.isLoading,
                  autofocus: index == 0,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: _length, // allows a full paste into one box
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.radius12,
                      ),
                      borderSide: BorderSide(color: AppColors.secondaryLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.radius12,
                      ),
                      borderSide: BorderSide(color: AppColors.secondaryLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.radius12,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => _onChanged(index, value),
                ),
              ),
            );
          }),
        ),
        AppDimens.spacerMedium,
        CustomButton(
          onPressed: widget.submit,
          text: 'Vérifier le code',
          isActive: _isComplete,
          isLoading: widget.isLoading,
        ),
      ],
    );
  }
}
