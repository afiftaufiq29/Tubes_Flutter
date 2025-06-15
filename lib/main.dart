import 'package:flutter/material.dart';
import 'package:tubes_flutter/screens/history_screen.dart';
import 'package:tubes_flutter/screens/home_screen.dart';
import 'package:tubes_flutter/screens/about_screen.dart';
import 'package:tubes_flutter/screens/register_screen.dart';
import 'package:tubes_flutter/screens/login_screen.dart';
import 'package:tubes_flutter/screens/menu_screen.dart';
import 'package:tubes_flutter/screens/reservation_screen.dart';
import 'package:tubes_flutter/screens/profile_screen.dart';
import 'package:tubes_flutter/screens/payment_screen.dart';
import 'package:tubes_flutter/models/food_model.dart';
import 'package:tubes_flutter/widgets/food_card.dart';
import 'package:tubes_flutter/constants/app_colors.dart';
import 'package:tubes_flutter/constants/app_styles.dart';
import 'package:tubes_flutter/services/api_service.dart'; // Import ApiService

Future<void> main() async {
  // Ubah menjadi async
  WidgetsFlutterBinding.ensureInitialized(); // Wajib ada untuk async main

  // Inisialisasi ApiService dan muat token dari penyimpanan
  await ApiService().initAuth();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masakan Nusantara',
      theme: _buildTheme(),
      initialRoute: '/login',
      routes: _buildRoutes(),
      onUnknownRoute: _onUnknownRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      fontFamily: 'Poppins',
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        titleTextStyle: AppStyles.headlineStyle.copyWith(
          color: AppColors.textColorLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColorPrimary,
          foregroundColor: AppColors.textColorLight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppStyles.headlineStyle,
        titleLarge: AppStyles.titleStyle,
        bodyLarge: AppStyles.bodyStyle,
        labelMedium: AppStyles.subtitleStyle,
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/home': (context) => const HomeScreen(),
      '/about': (context) => const AboutScreen(),
      '/menu': (context) => const MenuScreen(),
      '/reservation': (context) => const ReservationScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/history': (context) => const HistoryScreen(),
      '/payment': (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['reservationData'] != null &&
            args['selectedItems'] != null &&
            args['totalAmount'] != null) {
          return PaymentScreen(
            reservationData: args['reservationData'],
            selectedItems: args['selectedItems'],
            totalAmount: args['totalAmount'],
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('Kesalahan')),
            body: const Center(child: Text('Data pembayaran tidak lengkap.')),
          );
        }
      },
      '/food-cart': (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is FoodModel) {
          return Scaffold(
            appBar: AppBar(title: Text(args.name)),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              // ==================== PERUBAHAN DI SINI ====================
              // Menambahkan parameter onTap dan onAddToCart yang wajib.
              // Di sini kita berikan fungsi placeholder karena halaman ini
              // tidak memiliki konteks keranjang belanja.
              child: FoodCard(
                food: args,
                onTap: () {
                  // Tidak ada aksi khusus yang diperlukan saat diketuk di halaman ini
                  print("Card tapped on its own page: ${args.name}");
                },
                onAddToCart: () {
                  // Menampilkan notifikasi sederhana karena tidak ada
                  // state keranjang belanja di rute ini.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${args.name} ditambahkan ke keranjang.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              // ==========================================================
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Data makanan diperlukan')),
          );
        }
      },
    };
  }

  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Halaman Tidak Ditemukan'),
          backgroundColor: AppColors.errorColor,
        ),
        body: Center(
          child: Text(
            'Maaf, halaman ${settings.name} tidak ditemukan.',
            style: AppStyles.bodyStyle.copyWith(
              color: AppColors.errorColor,
            ),
          ),
        ),
      ),
    );
  }
}
