// lib/screens/debug_settings_screen.dart
import 'package:flutter/material.dart';
import '../services/shopify_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class DebugSettingsScreen extends StatefulWidget {
  const DebugSettingsScreen({Key? key}) : super(key: key);

  @override
  State<DebugSettingsScreen> createState() => _DebugSettingsScreenState();
}

class _DebugSettingsScreenState extends State<DebugSettingsScreen> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildAppInfoSection(),
                const Divider(),
                _buildShopifySection(),
                const Divider(),
                _buildDeviceInfoSection(),
                const Divider(),
                _buildActionsSection(),
              ],
            ),
    );
  }

  Widget _buildAppInfoSection() {
    return ListTile(
      title: const Text(
        'App Information',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoItem('App Name', _packageInfo?.appName ?? 'N/A'),
          _infoItem('Package Name', _packageInfo?.packageName ?? 'N/A'),
          _infoItem('Version', _packageInfo?.version ?? 'N/A'),
          _infoItem('Build Number', _packageInfo?.buildNumber ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildShopifySection() {
    return ListTile(
      title: const Text(
        'Shopify Configuration',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoItem('Store Domain', ShopifyConfig.shopDomain),
          _infoItem('API Version', ShopifyConfig.apiVersion),
          _infoItem(
            'Access Token',
            '${ShopifyConfig.storefrontAccessToken.substring(0, 4)}...${ShopifyConfig.storefrontAccessToken.substring(ShopifyConfig.storefrontAccessToken.length - 4)}',
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoSection() {
    return ListTile(
      title: const Text(
        'Device Information',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoItem('Platform', Platform.operatingSystem),
          _infoItem('OS Version', Platform.operatingSystemVersion),
          _infoItem('Dart Version', Platform.version),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Debug Actions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('Test Shopify Connection'),
          onTap: () {
            Navigator.pushNamed(context, '/shopify-debug');
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Clear App Data'),
          subtitle: const Text('Removes all local data and cache'),
          onTap: () => _showClearDataDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report_outlined),
          title: const Text('Generate Test Error'),
          subtitle: const Text('Creates a test error for debugging'),
          onTap: () => _generateTestError(),
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearDataDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text(
          'This will remove all local data including cart items and saved preferences. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              // Implement clear data logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App data cleared')),
              );
            },
            child: const Text('CLEAR'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _generateTestError() {
    try {
      throw Exception('Test error generated from debug menu');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}