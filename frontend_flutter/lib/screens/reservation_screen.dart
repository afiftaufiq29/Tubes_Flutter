import 'package:flutter/material.dart';
import '../utils/validation_helper.dart';

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
              color:
                  Colors.white, // Warna teks diubah menjadi putih untuk kontras
            )),
        centerTitle: true,
        elevation: 4, // Sedikit elevation untuk efek bayangan
        backgroundColor: Colors.orange[400], // Warna kuning/orange
        iconTheme:
            const IconThemeData(color: Colors.white), // Warna ikon back putih
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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _preorderMenu = false;
  bool _isSubmitting = false;

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
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
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
              surface: Colors.white,
              onSurface: Colors.black,
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

  // Di dalam class ReservationFormState

  void _processReservation() {
    setState(() => _isSubmitting = true);

    final reservationData = {
      'nama': _nameController.text,
      'telepon': _phoneController.text,
      'tanggal': _selectedDate!.toIso8601String(),
      'waktu': _selectedTime!.format(context),
      'catatan': _notesController.text,
    };

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // Hapus kondisi if(_preorderMenu) agar selalu navigasi
      Navigator.pushNamed(
        context,
        '/menu-reservation',
        arguments: {
          'reservationData': reservationData,
          'preorder': true,
        },
      );

      // Reset form setelah navigasi
      _formKey.currentState?.reset();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _preorderMenu = false;
      });
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      _processReservation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ Lengkapi semua data terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
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
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
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
        child: Text(
          value,
          style: TextStyle(
            color: _selectedDate == null && label == 'Tanggal' ||
                    _selectedTime == null && label == 'Waktu'
                ? Colors.grey[500]
                : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.orange[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'PILIH MENU',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
