import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart'; // Ganti dari SharedPreferences ke ApiService
import '../models/order_model.dart'; // Gunakan model data dari API
import '../models/food_model.dart'; // Impor ini untuk mengakses model 'Review'

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<OrderModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    // Memuat data dari API, bukan SharedPreferences
    _loadOrderHistoryFromApi();
  }

  void _loadOrderHistoryFromApi() {
    setState(() {
      // NOTE: The error "The method 'fetchOrderHistory' isn't defined"
      // means you need to add this method to your ApiService class.
      _historyFuture = _apiService.fetchOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Gunakan FutureBuilder untuk menangani state dari API call
      body: FutureBuilder<List<OrderModel>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat riwayat. Pastikan metode `fetchOrderHistory` ada di ApiService Anda dan backend berjalan.\n\nError: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat pesanan'),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // Format tanggal dari API
                  DateFormat('dd MMMM yyyy, HH:mm').format(order.orderDate),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'ID: #${order.id}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Loop melalui item di dalam order
            ...order.items.map((item) {
              // Kirim callback untuk me-refresh halaman setelah review berhasil
              return _MenuItemReviewCard(
                orderItem: item,
                onReviewSubmitted: _loadOrderHistoryFromApi,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// Pisahkan card item menjadi StatefulWidget sendiri untuk mengelola state rating & review
class _MenuItemReviewCard extends StatefulWidget {
  final OrderItemModel orderItem;
  final VoidCallback onReviewSubmitted;

  const _MenuItemReviewCard({
    required this.orderItem,
    required this.onReviewSubmitted,
  });

  @override
  State<_MenuItemReviewCard> createState() => __MenuItemReviewCardState();
}

class __MenuItemReviewCardState extends State<_MenuItemReviewCard> {
  final ApiService _apiService = ApiService();
  final TextEditingController _reviewController = TextEditingController();
  int? _currentRating;
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // FIXED: This function now creates a `Review` object to match the expected
  // argument type in your `ApiService.addReviewToFood` method.
  Future<void> _submitReview() async {
    if (_currentRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap berikan rating bintang terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Buat objek Review. Ini mengasumsikan model Review Anda memiliki
    // constructor `rating`, `comment`, dan `date`.
    final review = Review(
      rating: _currentRating!,
      comment: _reviewController.text,
      date: DateFormat('yyyy-MM-dd')
          .format(DateTime.now()), // Kirim tanggal saat ini
    );

    try {
      // Panggil API dengan argumen yang benar: int dan Review.
      // Ini akan memperbaiki error 'argument_type_not_assignable' dan 'extra_positional_arguments'.
      // Pastikan method `addReviewToFood` di ApiService Anda menerima (int foodId, Review review).
      await _apiService.addReviewToFood(
        widget.orderItem.menuItem.id, // ID dari menu item
        review,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ulasan Anda telah berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
      // Panggil callback untuk me-refresh data di halaman utama
      widget.onReviewSubmitted();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim ulasan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah item ini sudah pernah diberi ulasan dari data API
    // (Asumsi: Jika ada review, backend akan mengisinya di data `menuItem`)
    final bool hasExistingReview = widget.orderItem.menuItem.reviews.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.orderItem.menuItem
                        .name, // Ambil nama dari nested menuItem
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.orderItem.quantity}x',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tampilkan form review hanya jika belum ada review
            if (!hasExistingReview) ...[
              const Text(
                'Berikan Rating:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (starIndex) {
                  return IconButton(
                    onPressed: () =>
                        setState(() => _currentRating = starIndex + 1),
                    icon: Icon(
                      starIndex < (_currentRating ?? 0)
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.orange,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bagaimana pengalaman Anda?',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _reviewController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Tulis ulasan Anda (opsional)...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitReview,
                  icon: _isLoading
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.send, size: 20),
                  label: Text(
                    _isLoading ? 'Mengirim...' : 'Kirim Ulasan',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.orange.withOpacity(0.4),
                  ),
                ),
              ),
            ] else ...[
              // Tampilkan pesan bahwa ulasan sudah diberikan
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      'Anda sudah memberikan ulasan untuk item ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
