import 'package:flutter/material.dart'; // Pastikan Anda mengimpor material

class Review {
  final int rating;
  final String comment;
  final String date;

  Review({
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      // Handle cases where 'rating' might be a String or null
      rating: json['rating'] != null
          ? (json['rating'] is num
              ? (json['rating'] as num).toInt()
              : int.tryParse(json['rating'].toString()) ?? 0)
          : 0, // Default to 0 if rating is null or cannot be parsed
      comment: json['comment'] ?? '', // Handle nullable comment
      date: json['date'] ?? '', // Handle nullable date
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }
}

class FoodModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final double rating;
  List<Review> reviews;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.rating = 4.0,
    this.reviews = const [],
  });

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.map((r) => r.rating).reduce((a, b) => a + b);
    return total / reviews.length;
  }

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      // Ensure 'id' is parsed correctly. If it comes as a String, convert it.
      id: json['id'] != null
          ? (json['id'] is num
              ? (json['id'] as num).toInt()
              : int.tryParse(json['id'].toString()) ?? 0)
          : 0,
      name: json['name'] ?? '', // Handle nullable name
      description: json['description'] ?? '',
      // Perbaikan di sini: Coba parsing sebagai double dari String jika diperlukan
      price: json['price'] != null
          ? (json['price'] is num
              ? (json['price'] as num).toDouble()
              : double.tryParse(json['price'].toString()) ?? 0.0)
          : 0.0,
      imageUrl: json['image_url'], // Sesuaikan dengan nama kolom di Laravel
      isAvailable: json['is_available'] ??
          true, // Sesuaikan dengan nama kolom di Laravel
      // Perbaikan di sini: Coba parsing sebagai double dari String jika diperlukan
      rating: json['rating'] != null
          ? (json['rating'] is num
              ? (json['rating'] as num).toDouble()
              : double.tryParse(json['rating'].toString()) ?? 4.0)
          : 4.0,
      // For reviews, you'll need to decide how Laravel sends them.
      // If it's a separate API or embedded JSON, adjust accordingly.
      // For now, assuming reviews are not directly part of this JSON response, or handled differently.
      reviews: json['reviews'] != null
          ? List<Review>.from(json['reviews'].map((r) => Review.fromJson(r)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl, // Sesuaikan
      'is_available': isAvailable, // Sesuaikan
      'rating': rating,
      'reviews': reviews.map((r) => r.toJson()).toList(),
    };
  }
}
