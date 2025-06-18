// file: lib/order_summary_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';
import 'order_tracking_page.dart';
import 'home_page.dart';
class OrderSummaryPage extends StatelessWidget {
  final List<OrderItem> cart;
  final String restaurantName;
  final Function(Order) onOrderPlaced;

  const OrderSummaryPage({
    super.key,
    required this.cart,
    required this.restaurantName,
    required this.onOrderPlaced,
  });

  double get _totalPrice {
    return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      appBar: AppBar(
        title: const Text('Your Order', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final orderItem = cart[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${orderItem.quantity}x',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              orderItem.displayName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '\$${orderItem.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (orderItem.specialInstructions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Special: ${orderItem.specialInstructions}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('\$${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await AudioHelper.playAudio();
                      final finalOrder = Order(
                        id: Random().nextInt(99999).toString(),
                        restaurantName: restaurantName,
                        items: cart,
                        totalPrice: _totalPrice,
                        orderTime: DateTime.now(),
                        queueNumber: Random().nextInt(50) + 1,
                      );

                      onOrderPlaced(finalOrder);

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingPage(
                            order: finalOrder,
                            onOrderCancelled: () {},
                          ),
                        ),
                            (Route<dynamic> route) => route.isFirst,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Place Order', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}