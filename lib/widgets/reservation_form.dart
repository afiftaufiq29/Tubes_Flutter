import 'package:flutter/material.dart';
import '../utils/validation_helper.dart';

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
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _processReservation() {
    setState(() => _isSubmitting = true);

    // Simulasi proses async (misalnya API call)
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      final reservationData = {
        'nama': _nameController.text,
        'telepon': _phoneController.text,
        'tanggal': _selectedDate!.toIso8601String(),
        'waktu': _selectedTime!.format(context),
        'catatan': _notesController.text,
        'preorder': _preorderMenu,
      };

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _preorderMenu
                ? 'Reservasi berhasil! Silahkan pilih menu makanan'
                : 'Reservasi meja berhasil!',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );

      // Jika preorder, arahkan ke halaman menu
      if (_preorderMenu) {
        Navigator.pushNamed(
          context,
          '/menu',
          arguments: {
            'reservationData': reservationData,
            'preorder': true,
          },
        );
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      _processReservation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data terlebih dahulu.'),
          backgroundColor: Colors.red,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(),
              ),
              validator: ValidationHelper.validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Nomor Telepon",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: ValidationHelper.validatePhoneNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: "Catatan Tambahan (opsional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Tanggal Reservasi",
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Pilih Tanggal"
                      : "${_selectedDate!.toLocal().toString().split(' ')[0]}",
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Waktu Reservasi",
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedTime == null
                      ? "Pilih Waktu"
                      : _selectedTime!.format(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Ingin pesan makanan sekarang?'),
              value: _preorderMenu,
              onChanged: (value) {
                setState(() {
                  _preorderMenu = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text("Kirim Reservasi"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
