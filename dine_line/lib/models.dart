// file: lib/models.dart

// Represents an add-on option for a food item
class AddOn {
  final String name;
  final double price;

  AddOn({required this.name, required this.price});
}

// Represents a single food item on a menu
class FoodItem {
  final String name;
  final double price;
  final String imageUrl;
  final List<AddOn> availableAddOns;

  FoodItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.availableAddOns = const [],
  });
}

// Represents an item that has been added to the order
class OrderItem {
  final FoodItem foodItem;
  int quantity;
  final List<AddOn> selectedAddOns;
  final String specialInstructions;

  OrderItem({
    required this.foodItem,
    this.quantity = 1,
    this.selectedAddOns = const [],
    this.specialInstructions = '',
  });

  double get totalPrice {
    double addOnPrice = selectedAddOns.fold(0.0, (sum, addOn) => sum + addOn.price);
    return (foodItem.price + addOnPrice) * quantity;
  }

  int get estimatedTimeSeconds {
    // 30 seconds per item + 15 seconds per add-on
    return (30 + (selectedAddOns.length * 15)) * quantity;
  }

  String get displayName {
    if (selectedAddOns.isEmpty) return foodItem.name;
    String addOnNames = selectedAddOns.map((addOn) => addOn.name).join(', ');
    return '${foodItem.name} with $addOnNames';
  }
}

// Represents the status of a final, placed order
enum OrderStatus { placed, preparing, ready }

// Represents a final, confirmed order
class Order {
  final String id;
  final String restaurantName;
  final List<OrderItem> items;
  final double totalPrice;
  final DateTime orderTime;
  OrderStatus status;
  final int queueNumber;

  Order({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.totalPrice,
    required this.orderTime,
    this.status = OrderStatus.placed,
    required this.queueNumber,
  });

  int get totalEstimatedTimeSeconds {
    return items.fold(0, (sum, item) => sum + item.estimatedTimeSeconds);
  }

  String get formattedEstimatedTime {
    int totalSeconds = totalEstimatedTimeSeconds;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}