// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  // Properti untuk teks tombol
  final String text;

  // Properti untuk warna latar belakang tombol
  final Color backgroundColor;

  // Properti untuk warna teks tombol
  final Color textColor;

  // Properti untuk aksi ketika tombol ditekan
  final VoidCallback onPressed;

  // Konstruktor dengan parameter wajib
  const CustomButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Aksi ketika tombol ditekan
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor, // Warna latar belakang tombol
        foregroundColor: textColor, // Warna teks tombol
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ), // Padding tombol
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Border radius tombol
        ),
      ),
      child: Text(
        text, // Teks yang ditampilkan di tombol
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
