/*
================================================================================
| 2. File: lib/screens/menu_screen.dart (LENGKAP & FINAL)                      |
|------------------------------------------------------------------------------|
| Perubahan:                                                                   |
| - Memperbaiki logika `_fetchMenuItems` untuk menghindari cast yang tidak     |
|   perlu dan lebih mudah dibaca.                                              |
================================================================================
*/
import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/food_card.dart';
import '../widgets/food_detail_dialog.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ApiService _apiService = ApiService();

  // UI State
  int _selectedIndex = 1;
  bool _showFoods = true;
  bool _isLoading = true;
  String? _error;

  // State untuk alur Reservasi -> Pesanan
  int? reservationId;
  final Map<int, FoodModel> _cartItems = {};
  final Map<int, int> _itemQuantities = {};
  bool _isPlacingOrder = false;

  // Data
  List<FoodModel> _foodItems = [];
  List<FoodModel> _drinkItems = [];

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && reservationId == null) {
      setState(() {
        reservationId = args;
      });
    }
  }

  Future<void> _fetchMenuItems() async {
    setState(() => _isLoading = true);
    try {
      // Mengambil data makanan dan minuman secara terpisah untuk kejelasan
      final foods = await _apiService.fetchFoods();
      final drinks = await _apiService.fetchDrinks();

      if (mounted) {
        setState(() {
          _foodItems = foods;
          _drinkItems = drinks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat menu: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 2:
        Navigator.pushNamed(context, '/about');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _toggleFoods(bool showFoods) {
    if (_showFoods == showFoods) return;
    setState(() => _showFoods = showFoods);
  }

  void _addToCart(FoodModel food, {int quantity = 1}) {
    setState(() {
      if (_itemQuantities.containsKey(food.id)) {
        _itemQuantities[food.id] = _itemQuantities[food.id]! + quantity;
      } else {
        _cartItems[food.id] = food;
        _itemQuantities[food.id] = quantity;
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${food.name} (${_itemQuantities[food.id]}x) ditambahkan.'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _showFoodDetail(FoodModel food) async {
    await showDialog(
      context: context,
      builder: (context) => FoodDetailDialog(
        food: food,
        onAddToCart: (quantity) {
          _addToCart(food, quantity: quantity);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _handleCheckout() async {
    if (reservationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error: ID Reservasi tidak ditemukan.')));
      return;
    }
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keranjang Anda masih kosong.')));
      return;
    }

    setState(() => _isPlacingOrder = true);

    final itemsForApi = _itemQuantities.entries.map((entry) {
      return {'menu_item_id': entry.key, 'quantity': entry.value};
    }).toList();

    try {
      await _apiService.createOrder(
        reservationId: reservationId!,
        items: itemsForApi,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Pesanan Anda berhasil dibuat!'),
            backgroundColor: Colors.green));
        Navigator.pushNamedAndRemoveUntil(
            context, '/history', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<FoodModel> currentItems = _showFoods ? _foodItems : _drinkItems;
    final bool isReservationFlow = reservationId != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isReservationFlow ? 'Pilih Pesanan Anda' : 'Menu Kami',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[400]),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: isReservationFlow,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildCategoryButton('Makanan', true)),
                const SizedBox(width: 10),
                Expanded(child: _buildCategoryButton('Minuman', false)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red))))
                    : GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                            16, 0, 16, isReservationFlow ? 80 : 20),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8),
                        itemCount: currentItems.length,
                        itemBuilder: (context, index) {
                          final item = currentItems[index];
                          return FoodCard(
                            food: item,
                            onTap: () => _showFoodDetail(item),
                            onAddToCart: () => _addToCart(item),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: isReservationFlow
          ? FloatingActionButton.extended(
              onPressed: _isPlacingOrder ? null : _handleCheckout,
              backgroundColor: Colors.orange[400],
              icon: _isPlacingOrder
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3))
                  : const Icon(Icons.shopping_cart_checkout_rounded),
              label: Text(_isPlacingOrder
                  ? 'MEMPROSES...'
                  : 'PESAN SEKARANG (${_cartItems.length})'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: !isReservationFlow
          ? CustomBottomNavigationBar(
              currentIndex: _selectedIndex, onTap: _onItemTapped)
          : null,
    );
  }

  Widget _buildCategoryButton(String title, bool isFoodButton) {
    final bool isActive = isFoodButton == _showFoods;
    return ElevatedButton(
        onPressed: () => _toggleFoods(isFoodButton),
        style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.orange[400] : Colors.grey[200],
            foregroundColor: isActive ? Colors.white : Colors.black54,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: isActive ? 4 : 0),
        child:
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)));
  }
}
