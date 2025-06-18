// file: lib/home_page.dart

import 'package:flutter/material.dart';
import 'models.dart';
import 'store_details_page.dart';
import 'order_tracking_page.dart';
import 'package:audioplayers/audioplayers.dart';

// A simple data model for a restaurant
class Restaurant {
  final String name;
  final String imageUrl;
  final bool isOpen;
  final int waitTime;
  final List<FoodItem> menu;
  final int currentOrderNumber;
  final int totalOrders;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.isOpen,
    this.waitTime = 0,
    required this.menu,
    this.currentOrderNumber = 1,
    this.totalOrders = 5,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class AudioHelper {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  // Below is for the cart
  static Future<void> playAudio() async {
    await _audioPlayer.play(AssetSource('audio/button-pressed.mp3'));
  }

  static Future<void> playNormal() async {
    await _audioPlayer.play(AssetSource('audio/normal-click.mp3'));
  }

  static Future<void> orderMadness() async {
    await _audioPlayer.play(AssetSource('audio/pressing_order.mp3'));
  }
  static Future<void> cancelOrder() async {
    await _audioPlayer.play(AssetSource('audio/cancel_button_sound.mp3'));
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Order? _currentOrder; // Track if user has an active order

  // Dummy data with add-ons
  final List<Restaurant> _restaurants = [
    Restaurant(
      name: 'Chicken Rice Store',
      imageUrl: 'assets/chicken_rice.png',
      isOpen: true,
      waitTime: 15,
      currentOrderNumber: 23,
      totalOrders: 8,
      menu: [
        FoodItem(
          name: 'Roasted Chicken Rice',
          price: 4.50,
          imageUrl: 'assets/roasted_chicken.png',
          availableAddOns: [
            AddOn(name: 'Egg', price: 0.60),
            AddOn(name: 'Vegetables', price: 0.60),
            AddOn(name: 'Extra Meat', price: 1.20),
          ],
        ),
        FoodItem(
          name: 'Steamed Chicken Rice',
          price: 4.50,
          imageUrl: 'assets/steamed_chicken.png',
          availableAddOns: [
            AddOn(name: 'Egg', price: 0.60),
            AddOn(name: 'Vegetables', price: 0.60),
            AddOn(name: 'Extra Meat', price: 1.20),
          ],
        ),
        FoodItem(
          name: 'Chicken Porridge',
          price: 3.50,
          imageUrl: 'assets/chicken_porridge.png',
          availableAddOns: [
            AddOn(name: 'Century Egg', price: 0.80),
            AddOn(name: 'Salted Egg', price: 0.80),
          ],
        ),
      ],
    ),
    Restaurant(
      name: 'Fishball Noodle',
      imageUrl: 'assets/fishball_noodle.png',
      isOpen: true,
      waitTime: 10,
      currentOrderNumber: 15,
      totalOrders: 12,
      menu: [
        FoodItem(
          name: 'Fishball Noodle Soup',
          price: 4.00,
          imageUrl: 'assets/fishball_soup.png',
          availableAddOns: [
            AddOn(name: 'Extra Fishballs', price: 1.00),
            AddOn(name: 'Fish Cake', price: 0.80),
            AddOn(name: 'Vegetables', price: 0.50),
          ],
        ),
        FoodItem(
          name: 'Fishball Noodle Dry',
          price: 4.00,
          imageUrl: 'assets/fishball_dry.png',
          availableAddOns: [
            AddOn(name: 'Extra Fishballs', price: 1.00),
            AddOn(name: 'Fish Cake', price: 0.80),
            AddOn(name: 'Chili', price: 0.00),
          ],
        ),
        FoodItem(
          name: 'Laksa',
          price: 5.00,
          imageUrl: 'assets/laksa.png',
          availableAddOns: [
            AddOn(name: 'Extra Prawns', price: 1.50),
            AddOn(name: 'Cockles', price: 1.00),
            AddOn(name: 'Fish Cake', price: 0.80),
          ],
        ),
      ],
    ),
    Restaurant(
      name: 'Makun Bagus',
      imageUrl: 'assets/makun_bagus.png',
      isOpen: false,
      currentOrderNumber: 5,
      totalOrders: 3,
      menu: [
        FoodItem(
          name: 'Nasi Lemak',
          price: 3.50,
          imageUrl: 'assets/nasi_lemak.png',
          availableAddOns: [
            AddOn(name: 'Fried Chicken', price: 2.00),
            AddOn(name: 'Rendang', price: 2.50),
            AddOn(name: 'Extra Sambal', price: 0.50),
          ],
        ),
      ],
    ),
    Restaurant(
      name: 'Drinks Store',
      imageUrl: 'assets/drinks.png',
      isOpen: true,
      waitTime: 2,
      currentOrderNumber: 8,
      totalOrders: 15,
      menu: [
        FoodItem(
          name: 'Teh Tarik',
          price: 1.50,
          imageUrl: 'assets/teh_tarik.png',
          availableAddOns: [
            AddOn(name: 'Less Sugar', price: 0.00),
            AddOn(name: 'Extra Sweet', price: 0.20),
          ],
        ),
        FoodItem(
          name: 'Kopi O',
          price: 1.20,
          imageUrl: 'assets/kopi_o.png',
          availableAddOns: [
            AddOn(name: 'Less Sugar', price: 0.00),
            AddOn(name: 'Extra Sweet', price: 0.20),
          ],
        ),
      ],
    ),
    Restaurant(
      name: 'Waffles Store',
      imageUrl: 'assets/waffles.png',
      isOpen: false,
      currentOrderNumber: 2,
      totalOrders: 1,
      menu: [
        FoodItem(
          name: 'Original Waffle',
          price: 2.50,
          imageUrl: 'assets/original_waffle.png',
          availableAddOns: [
            AddOn(name: 'Chocolate Sauce', price: 0.50),
            AddOn(name: 'Ice Cream', price: 1.00),
            AddOn(name: 'Strawberries', price: 0.80),
          ],
        ),
      ],
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // If Orders tab is tapped and there's a current order, navigate to tracking
    if (index == 1 && _currentOrder != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderTrackingPage(
            order: _currentOrder!,
            onOrderCancelled: () {
              setState(() {
                _currentOrder = null;
              });
            },
          ),
        ),
      );
    }
  }

  void _onOrderPlaced(Order order) {
    setState(() {
      _currentOrder = order;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      appBar: AppBar(
        title: const Text('Dineline', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            const Text(
              'Nearby',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildRestaurantList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEB303).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search for food',
          hintStyle: TextStyle(color: Color(0xFF2F4293)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF2F4293)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
      ),
    );
  }

  Widget _buildRestaurantList() {
    return ListView.builder(
      itemCount: _restaurants.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return _RestaurantCard(
          restaurant: restaurant,
          hasActiveOrder: _currentOrder?.restaurantName == restaurant.name,
          onTap: () async {
            await AudioHelper.playNormal();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => StoreDetailsPage(
                restaurant: restaurant,
                onOrderPlaced: _onOrderPlaced,
              ),
            ));
          },
          onTrackOrder: _currentOrder != null ? () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderTrackingPage(
                  order: _currentOrder!,
                  onOrderCancelled: () {
                    setState(() {
                      _currentOrder = null;
                    });
                  },
                ),
              ),
            );
          } : null,
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: const Color(0xFFFFF8F6),
      selectedItemColor: const Color(0xFFB9191E),
      unselectedItemColor: Colors.grey[600],
      elevation: 5,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}

class _RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final bool hasActiveOrder;
  final VoidCallback onTap;
  final VoidCallback? onTrackOrder;

  const _RestaurantCard({
    required this.restaurant,
    required this.hasActiveOrder,
    required this.onTap,
    this.onTrackOrder,
  });

  @override
  State<_RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<_RestaurantCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: _isPressed
                  ? const Color(0xFFB9191E).withOpacity(0.2)
                  : _isHovered
                  ? const Color(0xFFFEB303).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey, size: 40),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.restaurant.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.restaurant.isOpen
                                ? 'Open ⋅ ${widget.restaurant.waitTime} min wait'
                                : 'Closed',
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.restaurant.isOpen
                                  ? const Color(0xFF2F4293)
                                  : const Color(0xFFB9191E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.hasActiveOrder && widget.onTrackOrder != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: widget.onTrackOrder,
                      child: const Text(
                        'Order Placed! Track order',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}