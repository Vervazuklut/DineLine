// file: lib/store_details_page.dart

import 'package:flutter/material.dart';
import 'models.dart';
import 'customize_page.dart';
import 'order_summary_page.dart';
import 'home_page.dart';
class StoreDetailsPage extends StatefulWidget {
  final Restaurant restaurant;
  final Function(Order) onOrderPlaced;

  const StoreDetailsPage({
    super.key,
    required this.restaurant,
    required this.onOrderPlaced,
  });

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  final List<OrderItem> _cart = [];

  void _addItemToCart(OrderItem orderItem) {
    setState(() {
      // Check if exact same item with same add-ons exists
      for (var item in _cart) {
        if (item.foodItem.name == orderItem.foodItem.name &&
            _areAddOnListsEqual(item.selectedAddOns, orderItem.selectedAddOns) &&
            item.specialInstructions == orderItem.specialInstructions) {
          item.quantity++;
          return;
        }
      }
      // If not found, add as new item
      _cart.add(orderItem);
    });
  }

  bool _areAddOnListsEqual(List<AddOn> list1, List<AddOn> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].name != list2[i].name) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      appBar: AppBar(
        title: Text(
          widget.restaurant.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Store info header
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EBE9),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Order: #${widget.restaurant.currentOrderNumber}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${widget.restaurant.totalOrders} orders in queue',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Menu items
          Expanded(
            child: ListView.builder(
              itemCount: widget.restaurant.menu.length,
              itemBuilder: (context, index) {
                final foodItem = widget.restaurant.menu[index];
                return _buildFoodItemTile(foodItem);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OrderSummaryPage(
              cart: _cart,
              restaurantName: widget.restaurant.name,
              onOrderPlaced: widget.onOrderPlaced,
            ),
          ));
        },
        label: Text('View Order (${_cart.length})'),
        icon: const Icon(Icons.shopping_cart),
        backgroundColor: Colors.orange,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFoodItemTile(FoodItem foodItem) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CustomizePage(
            foodItem: foodItem,
            onAddToOrder: _addItemToCart,
          ),
        ));
      },
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(Icons.image, color: Colors.grey, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${foodItem.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  if (foodItem.availableAddOns.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Customizable',
                      style: TextStyle(color: Colors.orange[700], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}