import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/custom_bottom_navigation_bar.dart';
import 'dart:ui';
// Removed: import '../services/mock_data.dart'; // This line is removed

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;
  double _scrollPosition = 0;
  late GoogleMapController _mapController;
  final LatLng _restaurantLocation =
      const LatLng(-6.966667, 107.633333); // Koordinat Bandung sebagai contoh
  bool _mapExpanded = false;
  double _mapHeight = 150;

  // Fungsi untuk format mata uang Rupiah
  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);
    _scrollController.addListener(_scrollListener);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _mapController.dispose();
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

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page!.toInt() + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
        Navigator.pushNamed(context, '/profile').then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
    }
  }

  void _handleSearch() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });

    // MockData is removed, so search results will always be empty
    final List<Map<String, dynamic>> allMenus = []; // Empty list
    final matchingItems = allMenus
        .where((menu) =>
            (menu['name'] as String).toLowerCase().contains(_searchQuery))
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            matchingItems.isNotEmpty
                ? 'Ditemukan ${matchingItems.length} menu'
                : 'Tidak ditemukan menu dengan kata kunci "$_searchQuery"',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor:
              matchingItems.isNotEmpty ? Colors.green : Colors.orange,
        ),
      );
    });
  }

  Widget _buildSearchResults() {
    // MockData is removed, so search results will always be empty
    final List<Map<String, dynamic>> allMenus = []; // Empty list
    final matchingItems = allMenus
        .where((menu) =>
            (menu['name'] as String).toLowerCase().contains(_searchQuery))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hasil Pencarian (${matchingItems.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        if (matchingItems.isNotEmpty)
          ...matchingItems.map((menu) => _buildMenuItem(
                menu['name'] as String,
                menu['imageUrl'] as String,
                menu['price'] as double,
                4.5, // Placeholder rating
                menu['description'] as String,
                true,
              )),
        if (matchingItems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'Tidak ditemukan menu dengan kata kunci "$_searchQuery"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
      ],
    );
  }

  Future<void> _openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query= ${_restaurantLocation.latitude},${_restaurantLocation.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _toggleMapSize() {
    setState(() {
      _mapExpanded = !_mapExpanded;
      _mapHeight = _mapExpanded ? 300 : 150;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _showAppBar
          ? AppBar(
              title: Text(
                'Masakan Nusantara',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[400],
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
            )
          : null,
      body: SafeArea(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Banner Slider
                  SizedBox(
                    height: 160,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final images = [
                          'assets/images/background_images/banner_1.jpg',
                          'assets/images/background_images/banner_2.jpg',
                          'assets/images/background_images/banner_3.jpg',
                        ];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar with search action
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari Menu...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.arrow_forward,
                                  color: Colors.orange[400]),
                              onPressed: _handleSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                    onSubmitted: (_) => _handleSearch(),
                  ),
                  const SizedBox(height: 20),
                  // Interactive Map Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  color: Colors.orange[400]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Ruko Buah Batu',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Jl. Terusan Buah Batu No.5, Batununggal, Kec. Bandung Kidul, Kota Bandung, Jawa Barat 40266',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: _mapHeight,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _restaurantLocation,
                                    zoom: 15,
                                  ),
                                  onMapCreated: (controller) {
                                    setState(() {
                                      _mapController = controller;
                                    });
                                  },
                                  markers: {
                                    Marker(
                                      markerId: const MarkerId('restaurant'),
                                      position: _restaurantLocation,
                                      infoWindow: const InfoWindow(
                                        title: 'Masakan Nusantara',
                                      ),
                                      icon:
                                          BitmapDescriptor.defaultMarkerWithHue(
                                              BitmapDescriptor.hueOrange),
                                    ),
                                  },
                                  gestureRecognizers: <Factory<
                                      OneSequenceGestureRecognizer>>{
                                    Factory<OneSequenceGestureRecognizer>(
                                      () => EagerGestureRecognizer(),
                                    ),
                                  },
                                  scrollGesturesEnabled: true,
                                  zoomGesturesEnabled: true,
                                  tiltGesturesEnabled: false,
                                  rotateGesturesEnabled: false,
                                  mapType: MapType.normal,
                                  zoomControlsEnabled: false,
                                  myLocationButtonEnabled: false,
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Column(
                                    children: [
                                      FloatingActionButton(
                                        heroTag: 'expand',
                                        mini: true,
                                        backgroundColor: Colors.white,
                                        onPressed: _toggleMapSize,
                                        child: Icon(
                                          _mapExpanded
                                              ? Icons.fullscreen_exit
                                              : Icons.fullscreen,
                                          color: Colors.orange[400],
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      FloatingActionButton(
                                        heroTag: 'navigate',
                                        mini: true,
                                        backgroundColor: Colors.white,
                                        onPressed: _openGoogleMaps,
                                        child: Icon(
                                          Icons.navigation,
                                          color: Colors.orange[400],
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Reservation Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/reservation'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'RESERVASI MENU',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 250, 250, 250),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search results or default menu
                  if (_searchQuery.isNotEmpty)
                    _buildSearchResults()
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Makanan Populer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Since MockData is removed, these lists will be empty.
                        // You'll need to replace them with real data if you want to display popular items.
                        ...<Map<String, dynamic>>[].map((food) =>
                            _buildMenuItem(
                                food['name'] as String,
                                food['imageUrl'] as String,
                                food['price'] as double,
                                4.5,
                                food['description'] as String,
                                false)),
                        const SizedBox(height: 16),
                        Text(
                          'Minuman Populer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Since MockData is removed, these lists will be empty.
                        // You'll need to replace them with real data if you want to display popular items.
                        ...<Map<String, dynamic>>[].map((drink) =>
                            _buildMenuItem(
                                drink['name'] as String,
                                drink['imageUrl'] as String,
                                drink['price'] as double,
                                4.5,
                                drink['description'] as String,
                                false)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  const SizedBox(height: 20),
                ],
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

  Widget _buildMenuItem(String title, String imagePath, double priceValue,
      double rating, String description, bool isHighlighted) {
    // Format harga menjadi Rupiah
    final formattedPrice = _formatCurrency(priceValue.toInt());

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isHighlighted ? Colors.orange[400]! : Colors.grey[300]!,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          _showFoodDetailDialog(
              title,
              imagePath,
              priceValue, // Mengirim nilai double untuk format
              rating,
              description);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 40),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedPrice, // Menggunakan harga yang sudah diformat
                      style: TextStyle(
                        color: Colors.orange[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFoodDetailDialog(String title, String imagePath, double priceValue,
      double rating, String description) {
    // Format harga menjadi Rupiah
    final formattedPrice = _formatCurrency(priceValue.toInt());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
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
                      child: Image.asset(
                        imagePath,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.fastfood, size: 50),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber[400]),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          formattedPrice, // Menggunakan harga yang sudah diformat
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
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
                      child: const Text("Tutup"),
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
}
