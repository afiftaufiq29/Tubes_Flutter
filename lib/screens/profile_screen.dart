import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../widgets/custom_bottom_navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 3;
  UserModel? currentUser;
  File? _profileImage;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditing = false;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;
  double _scrollPosition = 0;
  String memberSince = '';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotateController;
  late AnimationController _cardTapController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _cardTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _rotateController.repeat();

    _loadUserData();
    _loadProfileImage();
    _scrollController.addListener(_scrollListener);

    // Set member since time
    final now = DateTime.now();
    memberSince =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    _cardTapController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final currentScroll = _scrollController.offset;
    if (currentScroll > _scrollPosition && currentScroll > 50) {
      if (_showAppBar) {
        setState(() => _showAppBar = false);
      }
    } else if (currentScroll < _scrollPosition) {
      if (!_showAppBar) {
        setState(() => _showAppBar = true);
      }
    }
    _scrollPosition = currentScroll;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    setState(() {
      if (userData != null) {
        final Map<String, dynamic> userMap = json.decode(userData);
        currentUser = UserModel(
          name: userMap['name'] ?? 'Nama Pengguna',
          email: userMap['email'] ?? '',
          phone: userMap['phone'] ?? '',
          joinDate: userMap['joinDate'] ?? memberSince,
          password: userMap['password'] ?? '',
        );
      } else {
        currentUser = dummyUsers[0];
      }
      _nameController.text = currentUser?.name ?? 'Nama Pengguna';
      _emailController.text = currentUser?.email ?? '';
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImagePath = imagePath;
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> userMap = currentUser!.toJson();
    await prefs.setString('user_data', json.encode(userMap));

    if (_profileImagePath != null) {
      await prefs.setString('profile_image_path', _profileImagePath!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil disimpan'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    if (!_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktifkan mode edit untuk mengubah foto profil'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );

    if (image != null) {
      // Save to app directory for persistence
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String newPath =
          '${appDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImage = await File(image.path).copy(newPath);

      // Save the path to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', newPath);

      setState(() {
        _profileImage = newImage;
        _profileImagePath = newPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fromCamera
              ? 'Foto profil berhasil diambil'
              : 'Foto profil berhasil dipilih'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveChanges();
      }
    });
  }

  void _saveChanges() {
    setState(() {
      currentUser = UserModel(
        name: _nameController.text,
        email: _emailController.text,
        password: currentUser?.password ?? '',
        phone: currentUser?.phone ?? '',
        joinDate: memberSince,
      );
      _saveUserData();
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    // Animate before navigation
    _slideController.reverse().then((_) {
      if (mounted) {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
            break;
          case 1:
            Navigator.pushNamed(context, '/menu').then((_) {
              if (mounted) setState(() => _selectedIndex = 0);
            });
            break;
          case 2:
            Navigator.pushNamed(context, '/about').then((_) {
              if (mounted) setState(() => _selectedIndex = 0);
            });
            break;
          case 3:
            // Already on profile screen
            _slideController.forward();
            break;
        }
      }
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Konfirmasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Apakah Anda yakin ingin keluar dari akun?'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: const Text(
                        'Tidak',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        // Hapus hanya data sesi (jika ada)
                        // await prefs.remove('session_token');
                        // atau tidak hapus sama sekali

                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Berhasil keluar'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Ya'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.orange),
                  title: const Text('Ambil Foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(fromCamera: true);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: Colors.orange),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(fromCamera: false);
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal',
                      style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _isEditing ? _showImageSourceDialog : null,
      child: AnimatedBuilder(
        animation: _cardTapController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_cardTapController.value * 0.05),
            child: child,
          );
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 20, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _showAppBar
          ? AppBar(
              title: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) => FadeTransition(
                  opacity: _fadeController,
                  child: Transform.translate(
                    offset: Offset(0, (1 - _fadeController.value) * 20),
                    child: const Text(
                      'Profil Saya',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              actions: [
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * 3.1416,
                      child: IconButton(
                        icon: Icon(
                          _isEditing ? Icons.check : Icons.edit,
                          color: Colors.orange,
                        ),
                        onPressed: _toggleEditMode,
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutQuint,
            )),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  if (notification.metrics.axis == Axis.vertical) {
                    return true;
                  }
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Header Profil dengan Gradient
                    Container(
                      padding: const EdgeInsets.only(top: 24, bottom: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.orange.withOpacity(0.1),
                            Colors.orange[50]!,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildProfileImage(),
                          const SizedBox(height: 80),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: _isEditing
                                ? TextField(
                                    controller: _nameController,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      hintStyle:
                                          TextStyle(color: Colors.white70),
                                    ),
                                  )
                                : Text(
                                    currentUser?.name ?? 'Nama Pengguna',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Member sejak $memberSince',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Kartu Informasi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildModernInfoCard(
                            icon: Icons.person_outline,
                            title: "Informasi Pribadi",
                            items: [
                              _buildInfoItem('Nama Lengkap',
                                  currentUser?.name ?? 'Nama Pengguna'),
                              _buildInfoItem('Email', currentUser?.email ?? ''),
                              _buildInfoItem('Bergabung', memberSince),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildModernInfoCard(
                            icon: Icons.security_outlined,
                            title: "Keamanan Akun",
                            items: [
                              _buildInfoItem('Password', '••••••••'),
                              if (_isEditing)
                                _buildActionItem(
                                  'Ubah Password',
                                  Icons.arrow_forward_ios,
                                  action: _showChangePasswordDialog,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildModernInfoCard(
                            icon: Icons.history_outlined,
                            title: "Riwayat Pesanan",
                            items: [
                              _buildActionItem(
                                'Lihat Riwayat Pesanan',
                                Icons.arrow_forward_ios,
                                action: () {
                                  Navigator.pushNamed(context, '/history');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tombol Logout
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.red[200]!),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _handleLogout,
                          child: Text(
                            'Keluar',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildModernInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _isEditing && (label == 'Nama Lengkap' || label == 'Email')
              ? TextField(
                  controller: label == 'Nama Lengkap'
                      ? _nameController
                      : _emailController,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                    fontSize: 15,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String label, IconData icon, {Function()? action}) {
    return InkWell(
      onTap: action,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                fontSize: 15,
              ),
            ),
            Icon(icon, size: 16, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController _oldPasswordController =
        TextEditingController();
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ubah Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_oldPasswordController.text !=
                            currentUser?.password) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password lama tidak sesuai'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (_newPasswordController.text !=
                            _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Konfirmasi password tidak sesuai'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          currentUser = UserModel(
                            name: currentUser!.name,
                            email: currentUser!.email,
                            password: _newPasswordController.text,
                            phone: currentUser!.phone,
                            joinDate: memberSince,
                          );
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password berhasil diubah'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserModel {
  final String name;
  final String email;
  final String phone;
  final String joinDate;
  final String password;

  UserModel({
    required this.name,
    required this.email,
    this.phone = '',
    required this.joinDate,
    this.password = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'joinDate': joinDate,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? 'Nama Pengguna',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      joinDate: json['joinDate'] ?? 'Jan 2023',
      password: json['password'] ?? '',
    );
  }
}

final List<UserModel> dummyUsers = [
  UserModel(
    name: 'John Doe',
    email: 'user1@example.com',
    phone: '+628123456789',
    joinDate: 'Jan 2023',
    password: 'password123',
  ),
  UserModel(
    name: 'Jane Smith',
    email: 'user2@example.com',
    phone: '+628987654321',
    joinDate: 'Feb 2023',
    password: 'password456',
  ),
];
