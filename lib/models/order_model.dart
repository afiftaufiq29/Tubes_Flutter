// lib/models/order_model.dart
import 'food_model.dart'; // Impor FoodModel

// Model untuk setiap item dalam order
class OrderItemModel {
  final int id;
  final int orderId;
  final int menuItemId;
  final int quantity;
  final double price;
  final FoodModel menuItem; // Data lengkap menu item

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.price,
    required this.menuItem,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      menuItemId: json['menu_item_id'],
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      // 'menu_item' adalah nama relasi yang kita eager load di Laravel
      menuItem: FoodModel.fromJson(json['menu_item']),
    );
  }
}

// Model untuk order utama
class OrderModel {
  final int id;
  final int userId;
  final String status;
  final double totalAmount;
  final DateTime orderDate;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      status: json['status'] ?? 'Completed',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      orderDate: DateTime.parse(json['created_at']),
      items: (json['items'] as List)
          .map((itemJson) => OrderItemModel.fromJson(itemJson))
          .toList(),
    );
  }
}
