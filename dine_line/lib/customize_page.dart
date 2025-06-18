// file: lib/customize_page.dart

import 'package:flutter/material.dart';
import 'models.dart';
import "home_page.dart";
class CustomizePage extends StatefulWidget {
  final FoodItem foodItem;
  final Function(OrderItem) onAddToOrder;

  const CustomizePage({
    super.key,
    required this.foodItem,
    required this.onAddToOrder,
  });

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  final List<AddOn> _selectedAddOns = [];
  final TextEditingController _instructionsController = TextEditingController();

  double get _totalPrice {
    double addOnPrice = _selectedAddOns.fold(0.0, (sum, addOn) => sum + addOn.price);
    return widget.foodItem.price + addOnPrice;
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      appBar: AppBar(
        title: const Text('Customize', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food item name
                  Text(
                    widget.foodItem.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${widget.foodItem.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Add-ons section
                  if (widget.foodItem.availableAddOns.isNotEmpty) ...[
                    const Text(
                      'Add-ons',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...widget.foodItem.availableAddOns.map((addOn) => _buildAddOnTile(addOn)),
                    const SizedBox(height: 24),
                  ],

                  // Special Instructions
                  const Text(
                    'Special Instructions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: TextField(
                      controller: _instructionsController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Any special requests?',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add to Order button
          Container(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await AudioHelper.orderMadness();
                  final orderItem = OrderItem(
                    foodItem: widget.foodItem,
                    selectedAddOns: List.from(_selectedAddOns),
                    specialInstructions: _instructionsController.text,
                  );
                  widget.onAddToOrder(orderItem);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Add to Order - \$${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnTile(AddOn addOn) {
    final isSelected = _selectedAddOns.contains(addOn);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${addOn.name} +\$${addOn.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedAddOns.add(addOn);
                } else {
                  _selectedAddOns.remove(addOn);
                }
              });
            },
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }
}