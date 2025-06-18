// file: lib/order_tracking_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart';
import "home_page.dart";
class OrderTrackingPage extends StatefulWidget {
  final Order order;
  final VoidCallback onOrderCancelled;

  const OrderTrackingPage({
    super.key,
    required this.order,
    required this.onOrderCancelled,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  String _timeTaken = '';
  bool _orderCancelled = false;

  @override
  void initState() {
    super.initState();
    _startOrderSimulation();
  }

  void _startOrderSimulation() {
    Timer(const Duration(seconds: 1800), () {
      if (mounted && !_orderCancelled) {
        setState(() {
          widget.order.status = OrderStatus.preparing;
        });
      }
    });

    Timer(const Duration(seconds: 1900), () {
      if (mounted && !_orderCancelled) {
        final duration = DateTime.now().difference(widget.order.orderTime);
        setState(() {
          widget.order.status = OrderStatus.ready;
          _timeTaken = '${duration.inMinutes} min ${duration.inSeconds % 60} sec';
        });
      }
    });
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await AudioHelper.cancelOrder();
                setState(() {
                  _orderCancelled = true;
                });
                widget.onOrderCancelled();
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void  _showOrderDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'YOUR ORDER',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ...widget.order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    '${item.quantity}x ${item.displayName}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                )),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_orderCancelled) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8F6),
        body: const Center(
          child: Text(
            'Order Cancelled',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      appBar: AppBar(
        title: const Text('Your Order', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTracker(widget.order.status),
            const SizedBox(height: 32),

            // Restaurant and order info
            Text(widget.order.restaurantName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Order #${widget.order.id}', style: const TextStyle(color: Colors.grey)),
            Text('Queue Number: ${widget.order.queueNumber}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange)),
            Text('Estimated Time: ${widget.order.formattedEstimatedTime}', style: const TextStyle(fontSize: 16, color: Colors.blue)),

            const Divider(height: 32),

            if (widget.order.status == OrderStatus.ready)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: Text(
                    'Time Taken: $_timeTaken',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ),

            Text('Order Summary', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: widget.order.items.length,
                itemBuilder: (context, index) {
                  final item = widget.order.items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.displayName, style: const TextStyle(fontWeight: FontWeight.w600))),
                            Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (item.specialInstructions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Special: ${item.specialInstructions}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ],
                        Text(
                          'Est. ${item.estimatedTimeSeconds}s',
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.order.status == OrderStatus.placed ? _cancelOrder : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      widget.order.status == OrderStatus.placed ? 'Cancel Order' : 'Cannot Cancel',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await AudioHelper.orderMadness();
                      _showOrderDetails();
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Show Order', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTracker(OrderStatus currentStatus) {
    final statuses = OrderStatus.values;
    return Row(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isActive = status.index <= currentStatus.index;
        final isCurrent = status.index == currentStatus.index;

        return Expanded(
          child: Column(
            children: [
              Icon(
                isCurrent ? Icons.radio_button_checked : Icons.check_circle,
                color: isActive ? Colors.orange : Colors.grey[300],
                size: 30,
              ),
              const SizedBox(height: 4),
              Text(
                status.name[0].toUpperCase() + status.name.substring(1),
                style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        );
      }),
    );
  }
}