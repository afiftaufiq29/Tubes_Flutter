import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;

import '../models/food_model.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';

class ApiService {
  // Pastikan ini adalah IP yang BENAR untuk lingkungan Anda
  // Untuk Android Emulator: 'http://10.0.2.2:8000/api'
  // Untuk iOS Simulator/Localhost: 'http://localhost:8000/api'
  // Untuk Physical Device (replace with your local IP): 'http://<your_local_ip>:8000/api'
  static const String _baseUrl =
      'http://192.168.1.4:8000/api'; // Sesuaikan ini!

  String? _authToken;

  // --- Authentication Token Management ---
  void setAuthToken(String token) {
    _authToken = token;
    if (kDebugMode) {
      print('Auth token set: $_authToken');
    }
  }

  String? getAuthToken() {
    return _authToken;
  }

  void clearAuthToken() {
    _authToken = null;
    if (kDebugMode) {
      print('Auth token cleared.');
    }
  }

  // Helper to get headers with optional authentication
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

  /// Registers a new user and sets the authentication token upon success.
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
      // Asumsi Laravel mengembalikan 'user' dan 'token' langsung di root
      // Sesuaikan jika struktur response berbeda (misal, 'data' => {'user': ..., 'token': ...})
      setAuthToken(responseData['token']);
      return UserModel.fromJson(responseData['user']);
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to register: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  /// Logs in a user and sets the authentication token upon success.
  Future<UserModel> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Asumsi Laravel mengembalikan 'user' dan 'token' langsung di root
      setAuthToken(responseData['token']);
      return UserModel.fromJson(responseData['user']);
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to login: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  /// Logs out the current user and clears the authentication token.
  Future<void> logoutUser() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      clearAuthToken();
      if (kDebugMode) {
        print('Logged out successfully');
      }
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to logout: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  /// Fetches the details of the currently authenticated user.
  Future<UserModel> fetchCurrentUser() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response
          .body)); // Laravel Passport/Sanctum user endpoint returns User model directly
    } else {
      throw Exception(
          'Failed to load user: Status Code: ${response.statusCode}');
    }
  }

  // --- Food Endpoints (Menus) ---

  /// Fetches a list of all food items (menus).
  Future<List<FoodModel>> fetchFoods() async {
    final url = Uri.parse('$_baseUrl/foods');
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(), // No auth needed for public food listings
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

  // Based on your original code, 'fetchDrinks' also returns FoodModel.
  // If 'drinks' are a separate category, you might want a distinct model or endpoint.
  /// Fetches a list of drink items. Assumes drinks are also represented by `FoodModel`.
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

  /// Fetches a single food item by its ID.
  Future<FoodModel> fetchFoodById(int id) async {
    // Changed id type to int
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

  // Note: These CRUD methods for food/drink below (addFood, updateFood, deleteFood)
  // are likely meant for an ADMIN PANEL API.
  // Your current Laravel backend uses `admin/menu_items` for web UI,
  // and `foods`/`drinks` API endpoints are for listing.
  // If you also want to manage CRUD for menu items via API (e.g., from a separate admin app),
  // you'd need dedicated API routes for `menu_items` resource in Laravel.
  // For now, these methods *might* not match your Laravel routes perfectly.
  // Assumes `foods` endpoint in Laravel can handle full CRUD.

  /// Adds a new food item. Requires authentication.
  Future<FoodModel> addFood(FoodModel food) async {
    // Note: Laravel's MenuItemController store method expects 'image' as file, not 'image_url' in JSON.
    // This method needs to be modified if you intend to upload image file directly from Flutter.
    // For now, it assumes imageUrl is sent as a string and backend handles it.
    // If you plan to send files from Flutter, use `http.MultipartRequest`.
    final response = await http.post(
      Uri.parse(
          '$_baseUrl/foods'), // Assuming this is an API endpoint for creating a new food item
      headers: _getHeaders(
          requireAuth:
              true), // Laravel needs a specific API endpoint for CRUD with auth
      body: jsonEncode(
          food.toJson()), // food.toJson() sends image_url, not an actual file
    );

    if (response.statusCode == 201) {
      // Assuming Laravel returns the created food item directly or inside 'food' key
      return FoodModel.fromJson(jsonDecode(
          response.body)); // Adjusted based on common Laravel API responses
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to add food: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  /// Updates an existing food item by its ID. Requires authentication.
  Future<FoodModel> updateFood(int id, FoodModel food) async {
    // Changed id type to int
    // Similar note as addFood regarding image upload
    final response = await http.put(
      Uri.parse(
          '$_baseUrl/foods/$id'), // Assuming this is an API endpoint for updating a food item
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(food.toJson()),
    );

    if (response.statusCode == 200) {
      return FoodModel.fromJson(jsonDecode(
          response.body)); // Adjusted based on common Laravel API responses
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to update food: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  /// Deletes a food item by its ID. Requires authentication.
  Future<void> deleteFood(int id) async {
    // Changed id type to int
    final response = await http.delete(
      Uri.parse(
          '$_baseUrl/foods/$id'), // Assuming this is an API endpoint for deleting a food item
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Food deleted successfully');
      }
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to delete food: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  /// Adds a review to a specific food item. Requires authentication.
  Future<Review> addReviewToFood(int foodId, Review review) async {
    // Changed foodId type to int
    final response = await http.post(
      Uri.parse(
          '$_baseUrl/menu_items/$foodId/reviews'), // Corrected path to match Laravel's route
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(review.toJson()),
    );

    if (response.statusCode == 201) {
      // Laravel's addReview currently returns { message: 'Review added successfully!', menu_item: ... }
      // So, we might not get a 'review' key directly. Let's return the passed review for simplicity
      // or parse the 'menu_item' if you want the updated item.
      // For now, assuming Laravel confirms the review was added, we return the review object itself.
      // If Laravel returns the new Review object, parse it like: Review.fromJson(jsonDecode(response.body)['review'])
      return review; // Return the original review object if Laravel doesn't send the full new Review back
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to add review: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  // --- Reservation Endpoints ---
  // Assuming these models and endpoints are already configured correctly in Laravel

  /// Fetches a list of all reservations. Requires authentication.
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

  /// Adds a new reservation. Requires authentication.
  Future<ReservationModel> addReservation(ReservationModel reservation) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reservations'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(reservation.toJson()),
    );

    if (response.statusCode == 201) {
      // Assuming Laravel returns the created reservation directly or inside 'reservation' key
      return ReservationModel.fromJson(jsonDecode(
          response.body)); // Adjusted based on common Laravel API responses
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to add reservation: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  /// Updates an existing reservation by its ID. Requires authentication.
  Future<ReservationModel> updateReservation(
      int id, ReservationModel reservation) async {
    // Changed id type to int
    final response = await http.put(
      Uri.parse('$_baseUrl/reservations/$id'),
      headers: _getHeaders(requireAuth: true),
      body: jsonEncode(reservation.toJson()),
    );

    if (response.statusCode == 200) {
      return ReservationModel.fromJson(jsonDecode(
          response.body)); // Adjusted based on common Laravel API responses
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to update reservation: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }

  /// Deletes a reservation by its ID. Requires authentication.
  Future<void> deleteReservation(int id) async {
    // Changed id type to int
    final response = await http.delete(
      Uri.parse('$_baseUrl/reservations/$id'),
      headers: _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Reservation deleted successfully');
      }
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(
          'Failed to delete reservation: ${errorData['message'] ?? errorData['errors'] ?? 'Unknown error, Status Code: ${response.statusCode}'}');
    }
  }
}
