<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\MenuItemController; // Untuk rute admin UI dan get drinks
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FoodController; // Untuk rute API makanan
use App\Http\Controllers\Api\ReservationController; // Untuk rute API reservasi

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes (no authentication required)
// These routes are accessible to anyone without needing to log in.
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Routes for food and drink items, accessible publicly.
// Note: MenuItemController and FoodController might serve similar data,
// you may want to consolidate these if they represent the same data model.
Route::get('/foods', [FoodController::class, 'index']); // From Api\FoodController
Route::get('/foods/{id}', [FoodController::class, 'show']); // From Api\FoodController

// Ini adalah rute yang dipanggil oleh Flutter untuk mendapatkan minuman.
Route::get('/drinks-admin', [MenuItemController::class, 'getDrinkItems']); // From Admin\MenuItemController

// Sebuah rute tes sederhana untuk memastikan API berjalan.
Route::get('/test', function () {
    return response()->json(['message' => 'Hello from test route!']);
});

// Protected routes (requires authentication using Sanctum)
// Users must be authenticated to access these routes.
Route::middleware('auth:sanctum')->group(function () {
    // Rute terkait otentikasi pengguna untuk pengguna yang sudah diautentikasi.
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']); // Dapatkan detail pengguna yang diautentikasi

    // Rute manajemen makanan untuk pengguna yang sudah diautentikasi.
    Route::post('/foods', [FoodController::class, 'store']); // Buat item makanan baru
    Route::put('/foods/{id}', [FoodController::class, 'update']); // Perbarui item makanan yang sudah ada
    Route::delete('/foods/{id}', [FoodController::class, 'destroy']); // Hapus item makanan
    // Route Model Binding: {food} akan secara otomatis diresolusi menjadi instance MenuItem
    Route::post('/foods/{food}/reviews', [FoodController::class, 'addReview']); // Tambahkan ulasan ke item makanan

    // Rute manajemen reservasi untuk pengguna yang sudah diautentikasi.
    Route::get('/reservations', [ReservationController::class, 'index']); // Dapatkan semua reservasi
    Route::get('/reservations/{id}', [ReservationController::class, 'show']); // Dapatkan reservasi tertentu
    Route::post('/reservations', [ReservationController::class, 'store']); // Buat reservasi baru
    Route::put('/reservations/{id}', [ReservationController::class, 'update']); // Perbarui reservasi yang sudah ada
    Route::delete('/reservations/{id}', [ReservationController::class, 'destroy']); // Hapus reservasi
});