import 'dart:ui'; // Keep for ImageFilter
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tubes_flutter/utils/validation_helper.dart'; // Keep for validation
import 'package:tubes_flutter/services/api_service.dart'; // Import your ApiService
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(); // Changed to email
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService(); // Instantiate ApiService
  bool _isLoading = false;
  bool _showLoginForm = false;
  bool _showTitle = false;
  bool _exitToLeft = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showTitle = true);
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showLoginForm = true);
      });
    });
  }

  Future<void> _login(BuildContext context) async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password harus diisi')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = await _apiService.loginUser(email, password);
      // If login is successful, the token is already set in ApiService
      // and you can navigate to the home screen.

      setState(() => _exitToLeft = true);
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login berhasil! Selamat datang, ${user.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      // Tingkatkan pesan error yang ditampilkan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Login gagal: ${e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background dengan gambar dan blur effect
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assets/images/background_images/bg_login.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

          // Konten utama
          SafeArea(
            child: AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              left: _exitToLeft ? -MediaQuery.of(context).size.width : 0,
              right: _exitToLeft ? MediaQuery.of(context).size.width : 0,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  AnimatedOpacity(
                    opacity: _showTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    child: Transform(
                      transform:
                          Matrix4.translationValues(0, _showTitle ? 0 : 20, 0),
                      child: const Text(
                        'MASAKAN NUSANTARA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black45,
                              offset: Offset(2, 2),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutQuart,
                        )),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _showLoginForm
                        ? _buildLoginForm(context)
                        : const SizedBox(key: ValueKey('empty')),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        key: const ValueKey('loginForm'),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 25,
              spreadRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController, // Changed to email controller
              keyboardType: TextInputType.emailAddress, // Changed keyboard type
              decoration: InputDecoration(
                labelText: 'Email', // Changed label
                hintText: 'Contoh: user@example.com', // Changed hint
                prefixIcon: const Icon(Icons.email,
                    color: Colors.orange), // Changed icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
                ),
              ),
              validator: ValidationHelper
                  .validateEmail, // Assuming you have an email validator
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
                ),
              ),
              validator: ValidationHelper.validatePassword,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: Colors.orange.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
              child: RichText(
                text: TextSpan(
                  text: 'Belum punya akun? ',
                  style: TextStyle(color: Colors.grey[700]),
                  children: const [
                    TextSpan(
                      text: 'Daftar',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/loading_hand.json',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sedang memproses...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black45,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose(); // Dispose email controller
    _passwordController.dispose();
    super.dispose();
  }
}
