// lib/screens/shopify_debug_screen.dart
import 'package:flutter/material.dart';
import '../services/shopify_service.dart';
import '../services/shopify_debug.dart';

class ShopifyDebugScreen extends StatefulWidget {
  const ShopifyDebugScreen({Key? key}) : super(key: key);

  @override
  State<ShopifyDebugScreen> createState() => _ShopifyDebugScreenState();
}

class _ShopifyDebugScreenState extends State<ShopifyDebugScreen> {
  final ShopifyService _shopifyService = ShopifyService();
  late final ShopifyDebug _shopifyDebug;
  Map<String, dynamic>? _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopifyDebug = ShopifyDebug(_shopifyService);
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
      _status = null;
    });

    try {
      final status = await _shopifyDebug.getConnectionStatus();
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = {
          'status': 'error',
          'error': e.toString(),
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopify Debug'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigSection(),
            const SizedBox(height: 20),
            _buildTestSection(),
            if (_status != null) ...[
              const SizedBox(height: 20),
              _buildResultsSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildConfigItem('Store Domain', ShopifyConfig.shopDomain),
            _buildConfigItem('API Version', ShopifyConfig.apiVersion),
            _buildConfigItem(
              'Access Token', 
              '${ShopifyConfig.storefrontAccessToken.substring(0, 4)}...${ShopifyConfig.storefrontAccessToken.substring(ShopifyConfig.storefrontAccessToken.length - 4)}'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Center(
      child: ElevatedButton(
        onPressed: _isLoading ? null : _checkConnection,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Test Connection'),
      ),
    );
  }

  Widget _buildResultsSection() {
    final isSuccess = _status?['status'] == 'success';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isSuccess) ...[
              _buildResultItem('Products Found', _status?['productCount'].toString()),
              _buildResultItem('Response Time', '${_status?['responseTime']}ms'),
              if (_status?['details']?['sampleProduct'] != null)
                _buildResultItem('Sample Product', _status?['details']?['sampleProduct']),
            ] else ...[
              _buildResultItem('Error', _status?['error']),
              _buildResultItem('Timestamp', _status?['timestamp']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}