/*
================================================================================
| File: lib/services/api_service.dart (UPDATED)                                |
|------------------------------------------------------------------------------|
| Perubahan:                                                                   |
| 1. Diubah menjadi Singleton untuk memastikan hanya ada satu instance.        |
| 2. Token otentikasi sekarang akan konsisten di seluruh aplikasi.             |
================================================================================
*/
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

import '../models/food_model.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';

class ApiService {
  // Langkah 1: Buat constructor private.
  ApiService._internal();

  // Langkah 2: Buat satu instance statis & final.
  static final ApiService _instance = ApiService._internal();

  // Langkah 3: Buat factory constructor yang selalu mengembalikan instance yang sama.
  factory ApiService() {
    return _instance;
  }

  static const String _baseUrl =
      'http://192.168.1.18:8000/api'; // Sesuaikan IP Anda
  String? _authToken;
  static const String _tokenKey = 'auth_token'; // Kunci untuk SharedPreferences

  // --- Initialization ---
  /// Panggil ini saat aplikasi dimulai untuk memuat token dari penyimpanan.
  Future<void> initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      _authToken = token;
      if (kDebugMode) {
        print('Auth token loaded from storage into singleton instance.');
      }
    }
  }

  // --- Authentication Token Management ---
  Future<void> _setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _tokenKey, token); // Simpan token ke SharedPreferences
    if (kDebugMode) {
      print('Auth token set and saved: $_authToken');
    }
  }

  String? getAuthToken() {
    return _authToken;
  }

  Future<void> _clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey); // Hapus token dari SharedPreferences
    if (kDebugMode) {
      print('Auth token cleared.');
    }
  }

  Map<String, String> _getHeaders({bool requireAuth = false}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // --- Authentication Endpoints ---
  Future<UserModel> registerUser(String name, String email, String phone,
      String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      await _setAuthToken(
          responseData['token']); // Gunakan metode baru untuk menyimpan token
      return UserModel.fromJson(responseData['user']);
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to register: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error'}');
    }
  }

  Future<UserModel> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      await _setAuthToken(
          responseData['token']); // Gunakan metode baru untuk menyimpan token
      return UserModel.fromJson(responseData['user']);
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to login: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error'}');
    }
  }

  Future<void> logoutUser() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: _getHeaders(requireAuth: true),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Failed to notify server of logout, but proceeding: $e");
      }
    } finally {
      await _clearAuthToken(); // Hapus token dari lokal
    }
  }

  /// Fetches the details of the currently authenticated user.
  Future<UserModel> fetchCurrentUser() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to load user: Status Code: ${response.statusCode}');
    }
  }

  // --- Food Endpoints (Menus) ---
  Future<List<FoodModel>> fetchFoods() async {
    final url = Uri.parse('$_baseUrl/foods');
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> menuJson = json.decode(response.body);
        return menuJson.map((json) => FoodModel.fromJson(json)).toList();
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Failed to load foods: ${responseData['message'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<List<FoodModel>> fetchDrinks() async {
    final url = Uri.parse('$_baseUrl/drinks-admin');
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => FoodModel.fromJson(item)).toList();
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Failed to load drinks: ${responseData['message'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<FoodModel> fetchFoodById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/foods/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return FoodModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to load food: Status Code: ${response.statusCode}');
    }
  }

  Future<FoodModel> addFood(FoodModel food) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/foods'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(food.toJson()),
    );

    if (response.statusCode == 201) {
      return FoodModel.fromJson(jsonDecode(response.body));
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to add food: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  Future<FoodModel> updateFood(int id, FoodModel food) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/foods/$id'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(food.toJson()),
    );

    if (response.statusCode == 200) {
      return FoodModel.fromJson(jsonDecode(response.body));
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to update food: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  Future<void> deleteFood(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/foods/$id'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to delete food: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  // --- Review and Order Endpoints ---
  Future<Review> addReviewToFood(int foodId, Review review) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/foods/$foodId/reviews'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(review.toJson()),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      if (responseData['review'] != null) {
        return Review.fromJson(responseData['review']);
      }
      return review;
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to add review: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  Future<List<OrderModel>> fetchOrderHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders/history'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      final List<dynamic> historyJson = jsonDecode(response.body);
      return historyJson.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load order history: Status Code: ${response.statusCode}');
    }
  }

  // --- Reservation Endpoints ---
  Future<List<ReservationModel>> fetchReservations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reservations'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      List<dynamic> reservationJson = jsonDecode(response.body);
      return reservationJson
          .map((json) => ReservationModel.fromJson(json))
          .toList();
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to load reservations: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  Future<ReservationModel> addReservation(ReservationModel reservation) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reservations'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(reservation.toJson()),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return ReservationModel.fromJson(responseData['reservation']);
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to add reservation: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  Future<ReservationModel> updateReservation(
      int id, ReservationModel reservation) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/reservations/$id'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(reservation.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return ReservationModel.fromJson(responseData['reservation']);
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to update reservation: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  Future<void> deleteReservation(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/reservations/$id'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to delete reservation: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }
}
