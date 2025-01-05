// lib/onboarding/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/onboarding_page.dart';
import '../../screens/main_screen.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget
{
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
{
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Fresh & Healthy Grocery',
      image: 'assets/images/onboarding/fresh_grocery.png',
      description: 'Lorem ipsum dolor sit consectetur adipiscing elit.',
    ),
    OnboardingContent(
      title: 'Add to Cart',
      image: 'assets/images/onboarding/add_cart.png',
      description: 'Lorem ipsum dolor sit consectetur adipiscing elit.',
    ),
    OnboardingContent(
      title: 'Easy & Fast Delivery',
      image: 'assets/images/onboarding/delivery.png',
      description: 'Lorem ipsum dolor sit consectetur adipiscing elit.',
    ),
  ];

  @override
  Widget build(BuildContext context)
{
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contents.length,
                onPageChanged: (index)
{
                  setState(()
{
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index)
{
                  return OnboardingPage(content: _contents[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _contents.length,
                      (index) => buildDot(index),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // In onboarding_screen.dart
onPressed: () async
{
  if (_currentPage == _contents.length - 1)
{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHome', true);
    
    if (context.mounted)
{
      Navigator.pushReplacementNamed(context, AppRoutes.signup);
    }
  } else
{
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
},
                    child: Text(
                      _currentPage == _contents.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index)
{
    return Container(
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _currentPage == index ? Colors.green : Colors.grey,
      ),
    );
  }
}
