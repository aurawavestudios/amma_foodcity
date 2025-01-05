import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget
{
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context)
{
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Replace with actual cart items count
              itemBuilder: (context, index)
{
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/images/products/product1.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: const Text('Product Name'),
                    subtitle: const Text('£2.99'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: ()
{
                            // Decrease quantity
                          },
                        ),
                        const Text('1'), // Replace with actual quantity
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: ()
{
                            // Increase quantity
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:'),
                    Text(
                      '£8.97',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ()
{
                      Navigator.pushNamed(context, '/checkout');
                    },
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
