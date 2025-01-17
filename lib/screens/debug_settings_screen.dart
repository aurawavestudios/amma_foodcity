// lib/screens/debug_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import '../services/shopify_service.dart';
import '../services/category_manager.dart';
import '../services/shopify_category_service.dart';
import '../config/shopify_config.dart';

class DebugSettingsScreen extends StatefulWidget {
  const DebugSettingsScreen({Key? key}) : super(key: key);

  @override
  State<DebugSettingsScreen> createState() => _DebugSettingsScreenState();
}

class _DebugSettingsScreenState extends State<DebugSettingsScreen> {
  final ShopifyService _shopifyService = ShopifyService();
  late final CategoryManager _categoryManager;
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadPackageInfo();
  }

  void _initializeServices() {
    final shopifyClient = _shopifyService.getClient();
    _categoryManager = CategoryManager(ShopifyCategoryService(shopifyClient));
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
      _isLoading = false;
    });
  }

  Future<void> _testConnection() async {
    try {
      setState(() => _isLoading = true);
      final categories = await _categoryManager.getMainCategories();
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully fetched ${categories.length} categories'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          onTap: () => _testShopifyConnection(),
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Clear App Data'),
          subtitle: const Text('Removes all local data and cache'),
          onTap: () => _showClearDataDialog(),
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

  Future<void> _testShopifyConnection() async {
    try {
      final categories = await _categoryManager.getMainCategories();
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully fetched ${categories.length} categories'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
}