import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SocialMediaButton(
                icon: Icons.phone,
                label: 'Call',
                onTap: () => _launchURL('tel:+94123456789'),
              ),
              SocialMediaButton(
                icon: Icons.chat,
                label: 'WhatsApp',
                onTap: () => _launchURL('https://wa.me/94123456789'),
              ),
              SocialMediaButton(
                icon: Icons.location_on,
                label: 'Location',
                onTap: () => _launchURL('https://maps.google.com/?q=your_location'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SocialMediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SocialMediaButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}