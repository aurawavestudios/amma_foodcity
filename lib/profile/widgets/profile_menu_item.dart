import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget
{
  final IconData icon;
  final String title;
  final bool showDivider;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.showDivider = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context)
{
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        if (showDivider) const Divider(),
      ],
    );
  }
}
