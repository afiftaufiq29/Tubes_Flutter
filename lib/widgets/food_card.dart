import 'package:flutter/material.dart';
import '../models/food_model.dart';

class FoodCard extends StatelessWidget {
  final FoodModel food;

  const FoodCard({super.key, required this.food});

  // Fungsi untuk formatting harga
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: food.imageUrl != null &&
                      food.imageUrl!
                          .isNotEmpty // Periksa jika imageUrl tidak null dan tidak kosong
                  ? Image.network(
                      // Gunakan Image.network untuk gambar dari URL
                      food.imageUrl!, // Gunakan operator ! karena sudah diperiksa nullability
                      height: 95,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Tambahkan errorBuilder untuk gambar yang tidak bisa dimuat
                        return Container(
                          height: 95,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child:
                              Icon(Icons.broken_image, color: Colors.grey[600]),
                        );
                      },
                    )
                  : Container(
                      // Placeholder jika imageUrl null atau kosong
                      height: 95,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey[600]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    food.description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatHarga(
                            food.price), // Passing double to _formatHarga
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange,
                          height: 1.2,
                        ),
                      ),
                      if (food.reviews.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              food.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
