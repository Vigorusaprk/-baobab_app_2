import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget widget;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool isCenter;

  const CustomAppBar({
    super.key,
    this.leading,
    required this.widget,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.isCenter = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: isCenter,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: widget,
      actions: actions != null
          ? [...?actions, AppDimens.spacerAppPaddingLarge]
          : null,
    );
  }
}

class CustomOtherAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomOtherAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      widget: Text(title, style: Theme.of(context).textTheme.titleSmall),
      actions: actions,
      isCenter: true,
    );
  }
}
