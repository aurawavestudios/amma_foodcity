import 'package:flutter/material.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget
{
    const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context)
{
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.green,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Hasan Habib Hira',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'hasanhabibhira@gmail.com',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: [
                ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                ),
                ProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'My Address',
                ),
                ProfileMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'My Orders',
                ),
                ProfileMenuItem(
                  icon: Icons.payment_outlined,
                  title: 'Payment',
                ),
                ProfileMenuItem(
                  icon: Icons.message_outlined,
                  title: 'Message',
                ),
                ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Setting',
                ),
                ProfileMenuItem(
                  icon: Icons.logout_outlined,
                  title: 'Log Out',
                  showDivider: false,
                ),
              ],
            ),
          ],
        ),
      ),
    //   bottomNavigationBar: BottomNavigationBar(
    //     type: BottomNavigationBarType.fixed,
    //     selectedItemColor: Colors.green,
    //     unselectedItemColor: Colors.grey,
    //     items: [
    //       BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
    //       BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: 'Favorite'),
    //       BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
    //       BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
    //     ],
    //     currentIndex: 3,
    //   ),
    );
  }
}
