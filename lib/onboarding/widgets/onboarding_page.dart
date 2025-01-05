// lib/onboarding/widgets/onboarding_page.dart
import 'package:flutter/material.dart';

class OnboardingContent
{
  final String title;
  final String image;
  final String description;

  OnboardingContent({
    required this.title,
    required this.image,
    required this.description,
  });
}

class OnboardingPage extends StatelessWidget
{
  final OnboardingContent content;

  const OnboardingPage({super.key, required this.content});

  @override
  Widget build(BuildContext context)
{
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Image.asset(content.image, height: 300),
          const SizedBox(height: 20),
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
