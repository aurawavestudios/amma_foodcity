// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildMenuItems(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.green,
      child: const Column(
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
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'My Profile',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.location_on_outlined,
          title: 'My Address',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.shopping_bag_outlined,
          title: 'My Orders',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.payment_outlined,
          title: 'Payment',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.message_outlined,
          title: 'Messages',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () {},
        ),
        // Debug Section
        const Divider(thickness: 1),
        _buildMenuItem(
          icon: Icons.bug_report_outlined,
          title: 'Debug Menu',
          onTap: () => Navigator.pushNamed(context, AppRoutes.debugSettings),
          showDivider: false,
          isDebugItem: true,
        ),
        // Logout at the bottom
        const Divider(thickness: 1),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Logout',
          onTap: () {},
          showDivider: false,
          textColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
    bool isDebugItem = false,
    Color? textColor,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: textColor),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
          ),
          trailing: isDebugItem
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DEV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                )
              : const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}