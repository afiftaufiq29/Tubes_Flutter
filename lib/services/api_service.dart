import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_model.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';

class ApiService {
  // --- Singleton Setup ---
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // --- Configuration ---
  static const String _baseUrl =
      'http://192.168.1.30:8000/api'; // Pastikan IP ini benar
  String? _authToken;
  static const String _tokenKey = 'auth_token';

  // --- Initialization ---
  Future<void> initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      _authToken = token;
    }
  }

  // --- Helpers ---
  Future<void> _setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, String> _getHeaders({bool requireAuth = false}) {
    final headers = {
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
      final responseData = jsonDecode(response.body);
      await _setAuthToken(responseData['token']);
      return UserModel.fromJson(responseData['user']);
    } else {
      final errorData = jsonDecode(response.body);
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
      final responseData = jsonDecode(response.body);
      await _setAuthToken(responseData['token']);
      return UserModel.fromJson(responseData['user']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to login: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error'}');
    }
  }

  Future<void> logoutUser() async {
    try {
      await http.post(Uri.parse('$_baseUrl/logout'),
          headers: _getHeaders(requireAuth: true));
    } catch (e) {
      if (kDebugMode)
        print("Failed to notify server of logout, but proceeding: $e");
    } finally {
      await _clearAuthToken();
    }
  }

  Future<UserModel> fetchCurrentUser() async {
    final response = await http.get(Uri.parse('$_baseUrl/user'),
        headers: _getHeaders(requireAuth: true));
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to load user: Status Code: ${response.statusCode}');
    }
  }

  // --- Menu Endpoints ---
  Future<List<FoodModel>> fetchFoods() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/foods'), headers: _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> menuJson = json.decode(response.body);
      return menuJson.map((json) => FoodModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load foods: ${response.body}');
    }
  }

  Future<List<FoodModel>> fetchDrinks() async {
    // --- PENYESUAIAN DI SINI ---
    // Menggunakan endpoint /foods dengan parameter query untuk mendapatkan minuman.
    final url = Uri.parse('$_baseUrl/foods?type=drink');
    final response = await http.get(url, headers: _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> menuJson = json.decode(response.body);
      return menuJson.map((json) => FoodModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load drinks: ${response.body}');
    }
  }

  // --- Review & Order Endpoints ---
  Future<Review> addReviewToFood(int foodId, Review review) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/foods/$foodId/reviews'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(review.toJson()),
    );
    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['review'] != null
          ? Review.fromJson(responseData['review'])
          : review;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to add review: ${errorData['message'] ?? 'Unknown error'}');
    }
  }

  Future<List<OrderModel>> fetchOrderHistory() async {
    final response = await http.get(Uri.parse('$_baseUrl/orders/history'),
        headers: _getHeaders(requireAuth: true));
    if (response.statusCode == 200) {
      final List<dynamic> historyJson = jsonDecode(response.body);
      return historyJson.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load order history: Status Code: ${response.statusCode}');
    }
  }

  Future<OrderModel> createOrder(
      {required int reservationId,
      required List<Map<String, dynamic>> items}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode({'reservation_id': reservationId, 'items': items}),
    );
    if (response.statusCode == 201) {
      return OrderModel.fromJson(jsonDecode(response.body));
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Gagal membuat pesanan: ${errorData['message'] ?? errorData['errors']}');
    }
  }

  // --- Reservation Endpoints ---
  Future<ReservationModel> addReservation(ReservationModel reservation) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reservations'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(reservation.toJson()),
    );
    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return ReservationModel.fromJson(
          responseData['reservation'] ?? responseData['data'] ?? responseData);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to add reservation: ${errorData['message'] ?? 'Unknown error'}');
    }
  }
}
