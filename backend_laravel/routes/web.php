<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\MenuItemController;

// Admin Routes (for web UI)
Route::prefix('admin')->name('admin.')->group(function () {
    // You might want to add authentication middleware here like ->middleware('auth')
    Route::resource('menu_items', MenuItemController::class);
});

Route::get('/', function () {
    return view('welcome'); // Or redirect to admin login
});