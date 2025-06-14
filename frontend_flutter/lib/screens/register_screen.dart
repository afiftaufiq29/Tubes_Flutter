import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tubes_flutter/screens/home_screen.dart'; // Still here for potential navigation
import 'package:tubes_flutter/utils/validation_helper.dart';
import 'package:tubes_flutter/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showSuccessPopup = false;

  String _standardizePhone(String phone) {
    String cleanNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.startsWith("0")) {
      return "62${cleanNumber.substring(1)}";
    } else if (!cleanNumber.startsWith("62")) {
      return "62$cleanNumber";
    }
    return cleanNumber;
  }

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password dan Konfirmasi Password tidak cocok')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.registerUser(
        _nameController.text,
        _emailController.text,
        _phoneController.text.isNotEmpty
            ? _standardizePhone(_phoneController.text)
            : '',
        _passwordController.text,
        _confirmPasswordController.text,
      );

      setState(() {
        _isLoading = false;
        _showSuccessPopup = true;
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;
      // Navigate to LoginScreen after successful registration
      Navigator.pushReplacementNamed(context, '/login');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
      );
    } catch (e) {
      if (!mounted) return;
      // Tingkatkan pesan error yang ditampilkan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Registrasi gagal: ${e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _showSuccessPopup = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Akun',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange[400],
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange[400]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Konten utama, yang sekarang adalah anak langsung dari Stack
          AnimatedPositioned(
            // <--- Ini adalah anak langsung dari Stack
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: _isLoading
                ? -MediaQuery.of(context).size.width
                : 0, // Animate left when loading
            right: _isLoading
                ? MediaQuery.of(context).size.width
                : 0, // Animate right when loading
            child: SafeArea(
              // <--- SafeArea sekarang ada di dalam AnimatedPositioned
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.orange[50],
                        child: Icon(
                          Icons.person_add_alt_1,
                          size: 50,
                          color: Colors.orange[400],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildNameField(),
                      const SizedBox(height: 20),
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPhoneField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : () => _register(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.orange.withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading) _buildLoadingOverlay(),
          if (_showSuccessPopup) _buildSuccessPopup(context),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nama Lengkap',
        prefixIcon: Icon(Icons.person, color: Colors.orange[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: ValidationHelper.validateName,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email, color: Colors.orange[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: ValidationHelper.validateEmail,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Nomor HP',
        hintText: 'Contoh: 08123456789',
        prefixIcon: Icon(Icons.phone, color: Colors.orange[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: ValidationHelper.validatePhoneNumber,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock, color: Colors.orange[400]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.orange[400],
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: ValidationHelper.validatePassword,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Konfirmasi Password',
        prefixIcon: Icon(Icons.lock_reset, color: Colors.orange[400]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.orange[400],
          ),
          onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Konfirmasi password tidak boleh kosong';
        }
        if (value != _passwordController.text) {
          return 'Password tidak cocok';
        }
        return null;
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.orange[400],
              strokeWidth: 5,
            ),
            const SizedBox(height: 20),
            Text(
              'Memproses...',
              style: TextStyle(
                color: Colors.orange[400],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessPopup(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Blur Background
          SizedBox.expand(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),

          // Content
          Center(
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: Lottie.asset(
                            'assets/animations/centang.json',
                            fit: BoxFit.contain,
                            repeat: false,
                            frameRate: FrameRate.max,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Pendaftaran Berhasil!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.orange[400],
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
