// lib/constants/app_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const TextStyle headlineStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColorDark,
  );

  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textColorDark,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textColorDark,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textColorDark,
  );

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonColorPrimary,
    foregroundColor: AppColors.textColorLight,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: subtitleStyle.copyWith(color: AppColors.textColorLight),
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.buttonColorSecondary,
    side: BorderSide(color: AppColors.buttonColorPrimary),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: subtitleStyle,
  );

  static const BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBackgroundColor,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 3)),
    ],
  );
}
