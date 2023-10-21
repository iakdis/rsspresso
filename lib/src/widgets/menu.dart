import 'package:flutter/material.dart' hide SubmenuButton;
import 'package:flutter/material.dart' as material;

import '../utils/globals.dart';

ButtonStyle menuButtonStyle({required bool padding}) => ButtonStyle(
      maximumSize: const MaterialStatePropertyAll(
        Size.fromHeight(48.0),
      ),
      padding: padding
          ? const MaterialStatePropertyAll(
              EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
            )
          : null,
    );

MenuStyle menuStyle = const MenuStyle(
  padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 6.0)),
);

class Menu extends StatelessWidget {
  const Menu({
    super.key,
    required this.menuChildren,
    this.icon = Icons.more_horiz,
    this.tooltip,
  });

  final List<Widget> menuChildren;
  final IconData icon;
  final String? tooltip;

  Widget _menu() => MenuAnchor(
        builder: (context, controller, child) {
          return IconButton(
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
            icon: Icon(icon),
          );
        },
        menuChildren: menuChildren,
        style: menuStyle,
      );

  @override
  Widget build(BuildContext context) {
    return tooltip != null
        ? Tooltip(
            message: tooltip,
            child: _menu(),
          )
        : _menu();
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      style: menuButtonStyle(
          padding: MediaQuery.of(context).size.width > ScreenSize.mobileWidth),
      onPressed: onPressed,
      leadingIcon: Icon(icon),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class Submenu extends StatelessWidget {
  const Submenu({
    super.key,
    required this.text,
    required this.icon,
    required this.menuChildren,
  });

  final String text;
  final IconData icon;
  final List<Widget> menuChildren;

  @override
  Widget build(BuildContext context) {
    return material.SubmenuButton(
      style: menuButtonStyle(
          padding: MediaQuery.of(context).size.width > ScreenSize.mobileWidth),
      menuStyle: menuStyle,
      leadingIcon: Icon(icon),
      menuChildren: menuChildren,
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class SubmenuButton extends StatelessWidget {
  const SubmenuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.icon,
  });

  factory SubmenuButton.checked({
    required String text,
    required Function()? onPressed,
    required bool checked,
    IconData? icon,
  }) {
    return SubmenuButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      leading: checked ? const Icon(Icons.check) : const SizedBox(width: 24.0),
    );
  }

  final String text;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      style: menuButtonStyle(
          padding: MediaQuery.of(context).size.width > ScreenSize.mobileWidth),
      onPressed: onPressed,
      leadingIcon: leading,
      trailingIcon: trailing,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon),
            const SizedBox(width: 8.0),
          ],
          Text(text, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
