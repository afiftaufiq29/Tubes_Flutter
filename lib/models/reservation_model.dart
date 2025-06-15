// lib/models/reservation_model.dart

class ReservationModel {
  // Pastikan ada properti 'id' di sini. Jika tipenya int dari Laravel, gunakan int.
  final int id;
  final String name;
  final DateTime reservationDate;
  final String reservationTime;
  final int numberOfGuests;
  final String phoneNumber;
  final String? specialRequest;

  ReservationModel({
    required this.id, // Pastikan ada di constructor
    required this.name,
    required this.reservationDate,
    required this.reservationTime,
    required this.numberOfGuests,
    required this.phoneNumber,
    this.specialRequest,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      // Parsing 'id' dari JSON.
      id: json['id'],
      name: json['name'],
      // Ubah nama field JSON sesuai dengan yang dikirim Laravel
      reservationDate: DateTime.parse(json['reservation_date']),
      reservationTime: json['reservation_time'],
      numberOfGuests: json['number_of_guests'],
      phoneNumber: json['phone_number'],
      specialRequest: json['special_request'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id' biasanya tidak perlu dikirim saat membuat baru,
      // tapi tidak masalah jika ada.
      'id': id,
      'name': name,
      'reservation_date': reservationDate.toIso8601String().substring(0, 10),
      'reservation_time': reservationTime,
      'number_of_guests': numberOfGuests,
      'phone_number': phoneNumber,
      'special_request': specialRequest,
    };
  }
}
