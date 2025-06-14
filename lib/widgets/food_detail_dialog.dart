import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/food_model.dart';

class FoodDetailDialog extends StatelessWidget {
  final FoodModel food;

  const FoodDetailDialog({super.key, required this.food});

  String _formatHarga(double harga) {
    // Ubah tipe parameter menjadi double
    return 'Rp ${harga.toInt().toString().replaceAllMapped(
          // Convert to int sebelum formatting
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    String foodDescription = food.description;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: Colors.white.withOpacity(0.85),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: food.imageUrl != null &&
                            food.imageUrl!
                                .isNotEmpty // Periksa jika imageUrl tidak null dan tidak kosong
                        ? Image.network(
                            // Gunakan Image.network
                            food.imageUrl!, // Gunakan operator !
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey[600]),
                              );
                            },
                          )
                        : Container(
                            // Placeholder jika imageUrl null atau kosong
                            height: 150,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey[600]),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    foodDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatHarga(food.price), // Passing double to _formatHarga
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  // Tampilkan rating rata-rata
                  if (food.reviews.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 4),
                        Text(
                          food.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "(${food.reviews.length} ulasan)",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Bagian ulasan pengguna
                  if (food.reviews.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Apa kata mereka tentang menu ini?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      // Gunakan Expanded agar ListView mengambil sisa ruang yang tersedia
                      child: Container(
                        height:
                            200, // Ini akan diabaikan jika di dalam Expanded tanpa batasan tinggi eksternal
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: food.reviews.length,
                            itemBuilder: (context, index) {
                              final review = food.reviews[index];
                              return _buildReviewCard(review);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Tampilkan bintang
                ...List.generate(5, (index) {
                  return Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const Spacer(),
                Text(
                  _formatDate(review.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
