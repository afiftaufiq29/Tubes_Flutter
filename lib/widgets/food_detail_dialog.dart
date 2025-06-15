import 'package:flutter/material.dart';
import '../models/food_model.dart';

class FoodDetailDialog extends StatefulWidget {
  final FoodModel food;
  final ValueChanged<int> onAddToCart;

  const FoodDetailDialog({
    super.key,
    required this.food,
    required this.onAddToCart,
  });

  @override
  State<FoodDetailDialog> createState() => _FoodDetailDialogState();
}

class _FoodDetailDialogState extends State<FoodDetailDialog> {
  int quantity = 1;

  void _increment() => setState(() => quantity++);
  void _decrement() {
    if (quantity > 1) {
      setState(() => quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: Hero(
                    tag: 'food_image_${widget.food.id}',
                    child: Image.network(
                      widget.food.imageUrl ??
                          '[https://placehold.co/600x400/orange/white?text=Menu](https://placehold.co/600x400/orange/white?text=Menu)',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image,
                              color: Colors.grey[600])),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.food.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.food.description,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rp ${widget.food.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700)),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: _decrement,
                                  icon:
                                      const Icon(Icons.remove_circle_outline)),
                              Text('$quantity',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              IconButton(
                                  onPressed: _increment,
                                  icon: const Icon(Icons.add_circle_outline)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onAddToCart(quantity);
                          },
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: const Text('Tambah ke Pesanan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
