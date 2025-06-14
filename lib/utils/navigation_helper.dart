// lib/utils/navigation_helper.dart

import 'package:flutter/material.dart';

class NavigationHelper {
  // Navigasi ke halaman baru dengan nama rute
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  // Navigasi kembali ke halaman sebelumnya
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Navigasi ke halaman baru tanpa history (tidak bisa kembali)
  static void navigateAndReplaceAll(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  // Navigasi ke halaman baru dengan argumen
  static void navigateWithArguments(
    BuildContext context,
    String routeName,
    Object arguments,
  ) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }
}
