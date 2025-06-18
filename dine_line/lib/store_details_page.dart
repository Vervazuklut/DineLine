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
  int? _hoveredIndex;
  int? _pressedIndex;
  bool _isHovered = false;
  bool _isPressed = false;
  void _addItemToCart(OrderItem orderItem) {
    setState(() {
      // Check if exact same item with same add-ons exists
      for (var item in _cart) {
        if (item.foodItem.name == orderItem.foodItem.name &&
            _areAddOnListsEqual(item.selectedAddOns, orderItem.selectedAddOns) &&
            item.specialInstructions == orderItem.specialInstructions) {
          // Found matching item, increment quantity instead of replacing
          item.quantity += orderItem.quantity;
          print('Updated existing item: ${item.foodItem.name}, new quantity: ${item.quantity}');
          return;
        }
      }
      // If not found, add as new item
      _cart.add(orderItem);
      print('Added new item: ${orderItem.foodItem.name}, quantity: ${orderItem.quantity}');
    });
  }

  bool _areAddOnListsEqual(List<AddOn> list1, List<AddOn> list2) {
    if (list1.length != list2.length) return false;
    
    // Create sorted lists of add-on names for comparison
    List<String> names1 = list1.map((addOn) => addOn.name).toList()..sort();
    List<String> names2 = list2.map((addOn) => addOn.name).toList()..sort();
    
    for (int i = 0; i < names1.length; i++) {
      if (names1[i] != names2[i]) return false;
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
              color: const Color(0xFFFEB303).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Order: #${widget.restaurant.currentOrderNumber}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${widget.restaurant.totalOrders} orders in queue',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                return _buildFoodItemTile(foodItem, index); // Pass the index here
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () async {
          await AudioHelper.playAudio();
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
        backgroundColor: const Color(0xFFFEB303),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFoodItemTile(FoodItem foodItem, int index) {
    final bool isHovered = _hoveredIndex == index;
    final bool isPressed = _pressedIndex == index;

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
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressedIndex = index),
          onTapUp: (_) => setState(() => _pressedIndex = null),
          onTapCancel: () => setState(() => _pressedIndex = null),
          onTap: () async {
            await AudioHelper.playNormal();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CustomizePage(
                foodItem: foodItem,
                onAddToOrder: _addItemToCart,
              ),
            ));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isPressed
                  ? const Color(0xFFB9191E).withOpacity(0.2)
                  : isHovered
                  ? const Color(0xFFFEB303).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
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
                          style: TextStyle(color: Color(0xFFFEB303), fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}