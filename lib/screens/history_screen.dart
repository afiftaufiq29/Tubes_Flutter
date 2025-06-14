import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/food_model.dart'; // Assuming FoodModel and Review are still relevant for your models

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<OrderHistory> orderHistory = [];

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final orderHistoryData = prefs.getStringList('order_history') ?? [];

    setState(() {
      orderHistory = orderHistoryData
          .map((e) => OrderHistory.fromJson(json.decode(e)))
          .toList();
    });
  }

  Future<void> _saveOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> orderHistoryList =
        orderHistory.map((order) => json.encode(order.toJson())).toList();
    await prefs.setStringList('order_history', orderHistoryList);
  }

  // The _saveFoodReview function is removed as it relied on MockData.
  // If you need to save reviews to actual food/drink items, you'll need
  // to implement a new data storage mechanism for your FoodModel and Review models.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orderHistory.isEmpty
          ? const Center(
              child: Text('Belum ada riwayat pesanan'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                final order = orderHistory[index];
                return _buildOrderCard(order);
              },
            ),
    );
  }

  Widget _buildOrderCard(OrderHistory order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'ID: ${order.id}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => _buildMenuItemCard(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(OrderItem item) {
    TextEditingController reviewController = TextEditingController(
      text: item.review ?? '',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.quantity}x',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (item.rating == null || item.review == null) ...[
              const Text(
                'Berikan Rating:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (starIndex) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        item.rating = starIndex + 1;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starIndex < (item.rating ?? 0)
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.orange,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bagaimana pengalaman Anda?',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: reviewController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Tulis ulasan Anda...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (item.rating == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Harap berikan rating terlebih dahulu'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      item.review = reviewController.text;
                    });

                    await _saveOrderHistory();
                    // Removed _saveFoodReview(item) call as the function is removed.

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ulasan Anda telah disimpan!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send, size: 20),
                  label: const Text(
                    'Kirim Ulasan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.orange.withOpacity(0.4),
                  ),
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < (item.rating ?? 0); i++)
                    const Icon(Icons.star_rounded,
                        color: Colors.orange, size: 28),
                  for (int i = (item.rating ?? 0); i < 5; i++)
                    const Icon(Icons.star_border_rounded,
                        color: Colors.grey, size: 28),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Ulasan Anda:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.review!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OrderHistory {
  final String id;
  final String date;
  final List<OrderItem> items;

  OrderHistory({
    required this.id,
    required this.date,
    required this.items,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'],
      date: json['date'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String name;
  final int quantity;
  int? rating;
  String? review;

  OrderItem({
    required this.name,
    required this.quantity,
    this.rating,
    this.review,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
      rating: json['rating'],
      review: json['review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'rating': rating,
      'review': review,
    };
  }
}
