import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget
{
  final String icon;

  const SocialButton({required this.icon});

  @override
  Widget build(BuildContext context)
{
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(icon, height: 24),
    );
  }
}
