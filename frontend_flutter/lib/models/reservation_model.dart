// lib/models/reservation_model.dart

class ReservationModel {
  final String id;
  final String name;
  final DateTime reservationDate;
  final String reservationTime;
  final int numberOfGuests;
  final String phoneNumber;
  final String? specialRequest;

  ReservationModel({
    required this.id,
    required this.name,
    required this.reservationDate,
    required this.reservationTime,
    required this.numberOfGuests,
    required this.phoneNumber,
    this.specialRequest,
  });

  // Factory method untuk membuat objek dari JSON
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],
      name: json['name'],
      reservationDate: DateTime.parse(json['reservationDate']),
      reservationTime: json['reservationTime'],
      numberOfGuests: json['numberOfGuests'],
      phoneNumber: json['phoneNumber'],
      specialRequest: json['specialRequest'],
    );
  }

  // Method untuk mengonversi objek ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'reservationDate': reservationDate.toIso8601String(),
      'reservationTime': reservationTime,
      'numberOfGuests': numberOfGuests,
      'phoneNumber': phoneNumber,
      'specialRequest': specialRequest,
    };
  }
}
