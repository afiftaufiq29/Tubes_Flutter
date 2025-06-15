/*
================================================================================
| File: lib/screens/reservation_screen.dart (UPDATED)                          |
|------------------------------------------------------------------------------|
| Perubahan:                                                                   |
| 1. Mengimpor ApiService dan ReservationModel.                                |
| 2. Mengubah _processReservation menjadi async untuk memanggil API.           |
| 3. Setelah reservasi sukses, ID reservasi akan ditangkap.                    |
| 4. Navigasi diubah ke '/menu' sambil mengirim ID reservasi sebagai argumen.  |
================================================================================
*/
import 'package:flutter/material.dart';
import '../models/reservation_model.dart'; // <-- TAMBAHKAN INI
import '../services/api_service.dart'; // <-- TAMBAHKAN INI
import '../utils/validation_helper.dart';

// Widget ReservationScreen tidak perlu diubah, biarkan apa adanya.
class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Reservasi Menu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.orange[400],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: ReservationForm(),
        ),
      ),
    );
  }
}

class ReservationForm extends StatefulWidget {
  const ReservationForm({super.key});

  @override
  ReservationFormState createState() => ReservationFormState();
}

class ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _guestController =
      TextEditingController(text: '1'); // <-- TAMBAHKAN UNTUK JUMLAH TAMU
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  // Instance dari ApiService
  final ApiService _apiService = ApiService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[400]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[400]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  // --- LOGIKA UTAMA ADA DI SINI ---
  void _submitForm() async {
    // <-- Ubah menjadi async
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      setState(() => _isSubmitting = true);

      try {
        // 1. Buat objek ReservationModel dari data form
        final reservationData = ReservationModel(
          id: 0, // ID diisi 0, server akan meng-generate yang baru
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          reservationDate: _selectedDate!,
          reservationTime: _selectedTime!.format(context),
          numberOfGuests: int.tryParse(_guestController.text) ?? 1,
          specialRequest: _notesController.text,
        );

        // 2. Panggil API untuk membuat reservasi
        final newReservation =
            await _apiService.addReservation(reservationData);

        // 3. Jika berhasil, navigasi ke halaman menu dengan membawa ID
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservasi berhasil! Silakan pilih menu Anda.'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacementNamed(
            context,
            '/menu', // Arahkan ke menu screen yang sama
            arguments: newReservation.id, // Kirim ID reservasi yang baru dibuat
          );
        }
      } catch (e) {
        // 4. Jika gagal, tampilkan pesan error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat reservasi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // 5. Hentikan loading indicator
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ Lengkapi semua data terlebih dahulu'),
          backgroundColor: Colors.orange[400],
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _guestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSectionTitle('Informasi Dasar'),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _nameController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
              validator: ValidationHelper.validateName,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _phoneController,
              label: 'Nomor Telepon',
              icon: Icons.phone_iphone_outlined,
              keyboardType: TextInputType.phone,
              validator: ValidationHelper.validatePhoneNumber,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              // <-- TAMBAHKAN INPUT UNTUK JUMLAH TAMU
              controller: _guestController,
              label: 'Jumlah Tamu',
              icon: Icons.people_outline,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    (int.tryParse(value) ?? 0) <= 0) {
                  return 'Jumlah tamu tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _notesController,
              label: 'Catatan Khusus (opsional)',
              icon: Icons.note_add_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Waktu Reservasi'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimePicker(
                    label: 'Tanggal',
                    value: _selectedDate == null
                        ? 'Pilih Tanggal'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateTimePicker(
                    label: 'Waktu',
                    value: _selectedTime == null
                        ? 'Pilih Waktu'
                        : _selectedTime!.format(context),
                    icon: Icons.access_time_outlined,
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS (TIDAK ADA PERUBAHAN) ---
  Widget _buildSectionTitle(String text) => Text(text,
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]));
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) =>
      TextFormField(
          controller: controller,
          decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.grey[600]),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              filled: true,
              fillColor: Colors.white),
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines);
  Widget _buildDateTimePicker(
          {required String label,
          required String value,
          required IconData icon,
          required VoidCallback onTap}) =>
      InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
              decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  filled: true,
                  fillColor: Colors.white),
              child: Text(value,
                  style: TextStyle(
                      color: _selectedDate == null && label == 'Tanggal' ||
                              _selectedTime == null && label == 'Waktu'
                          ? Colors.grey[500]
                          : Colors.black))));
  Widget _buildSubmitButton() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange[400],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('PILIH MENU',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold))));
}
