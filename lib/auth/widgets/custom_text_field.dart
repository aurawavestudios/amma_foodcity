import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget
{
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;

  const CustomTextField({
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context)
{
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: isPassword ? Icon(Icons.visibility_off_outlined) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
