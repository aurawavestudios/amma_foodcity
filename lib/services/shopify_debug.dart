// lib/services/shopify_debug.dart
import 'package:flutter/material.dart';
import 'shopify_service.dart';

class ShopifyDebug {
  final ShopifyService _shopifyService;

  ShopifyDebug(this._shopifyService);

  Future<void> testConnection(BuildContext context) async {
    try {
      // Test products fetch
      final products = await _shopifyService.getProducts();
      
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Shopify Connection Test'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✅ Connection Successful'),
              const SizedBox(height: 8),
              Text('Products found: ${products.length}'),
              const SizedBox(height: 8),
              if (products.isNotEmpty) ...[
                const Text('Sample product:'),
                Text('Name: ${products.first.name}'),
                Text('Price: ${products.first.price}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Shopify Connection Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('❌ Connection Failed'),
              const SizedBox(height: 8),
              Text('Error: $e'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getConnectionStatus() async {
    try {
      final startTime = DateTime.now();
      final products = await _shopifyService.getProducts();
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return {
        'status': 'success',
        'productCount': products.length,
        'responseTime': responseTime,
        'details': {
          'sampleProduct': products.isNotEmpty ? products.first.name : null,
          'hasProducts': products.isNotEmpty,
          'apiVersion': ShopifyConfig.apiVersion,
        }
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}