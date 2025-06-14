<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MenuItem; // Menggunakan model MenuItem
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon; // Untuk tanggal jika diperlukan

class FoodController extends Controller
{
    /**
     * Display a listing of the food items.
     * Accessible via /api/foods
     */
    public function index()
    {
        // Ambil semua item yang bertipe 'food' dan tersedia
        $foods = MenuItem::where('type', 'food')->where('is_available', true)->get();
        // Berikan reviews kosong untuk kompatibilitas Flutter FoodModel
        $foods->each(function ($food) {
            $food->reviews = [];
        });
        return response()->json($foods);
    }

    /**
     * Display the specified food item.
     * Accessible via /api/foods/{id}
     */
    public function show($id)
    {
        $food = MenuItem::where('type', 'food')->where('id', $id)->firstOrFail();
        // Berikan reviews kosong untuk kompatibilitas Flutter FoodModel
        $food->reviews = [];
        return response()->json($food);
    }

    /**
     * Store a newly created food item.
     * Accessible via /api/foods (POST), requires auth
     */
    public function store(Request $request)
    {
        // Validasi data (sama seperti di Admin\MenuItemController)
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', // Jika Anda mengunggah file gambar
            'image_url' => 'nullable|string|max:255', // Jika Anda mengirim URL gambar
            'type' => 'required|in:food,drink', // Di sini harus selalu 'food' jika ini khusus FoodController
            'is_available' => 'boolean',
            'rating' => 'numeric|min:0|max:5',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $request->all();
        $data['type'] = 'food'; // Pastikan tipenya 'food' jika ini FoodController

        // Jika Anda menangani upload file, kode ini akan berbeda
        // Untuk saat ini, kita asumsikan image_url langsung dikirim atau dikosongkan.
        // Jika Anda ingin upload gambar dari Flutter, gunakan `MultipartRequest` dan sesuaikan logic di sini.

        $food = MenuItem::create($data);
        $food->reviews = []; // Untuk konsistensi response

        return response()->json($food, 201);
    }

    /**
     * Update the specified food item.
     * Accessible via /api/foods/{id} (PUT/PATCH), requires auth
     */
    public function update(Request $request, $id)
    {
        $food = MenuItem::where('type', 'food')->where('id', $id)->firstOrFail();

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'image_url' => 'nullable|string|max:255',
            'is_available' => 'boolean',
            'rating' => 'numeric|min:0|max:5',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $food->update($request->all());
        $food->reviews = []; // Untuk konsistensi response

        return response()->json($food, 200);
    }

    /**
     * Remove the specified food item from storage.
     * Accessible via /api/foods/{id} (DELETE), requires auth
     */
    public function destroy($id)
    {
        $food = MenuItem::where('type', 'food')->where('id', $id)->firstOrFail();
        // Opsional: Hapus gambar terkait jika ada
        if ($food->image_url) {
            Storage::disk('public')->delete(str_replace('/storage/', '', $food->image_url));
        }
        $food->delete();

        return response()->json(['message' => 'Food item deleted successfully'], 200);
    }

    /**
     * Add a review to a food item.
     * Accessible via /api/foods/{food}/reviews (POST), requires auth
     * Menggunakan route model binding: {food} akan otomatis jadi instance MenuItem.
     */
    public function addReview(Request $request, MenuItem $food) // Menggunakan MenuItem $food karena rute menangkap {food}
    {
        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
            'date' => 'required|date', // Validasi tanggal yang dikirim dari Flutter
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        // Pilihan 1: Jika Anda memiliki tabel reviews terpisah (DIREKOMENDASIKAN)
        // Pastikan Anda telah membuat Model Review dan migration `reviews` table.
        /*
        $review = $food->reviews()->create([
            'rating' => $request->rating,
            'comment' => $request->comment,
            'date' => $request->date, // Simpan tanggal dari Flutter
            // 'user_id' => auth()->id(), // Jika ada otentikasi user
        ]);

        // Hitung ulang rating rata-rata untuk food item
        $food->rating = $food->reviews()->avg('rating') ?? 0.0;
        $food->save();

        return response()->json(['message' => 'Review added successfully!', 'review' => $review], 201);
        */

        // Pilihan 2: Hanya update rating di MenuItem (JANGAN GUNAKAN INI JIKA ANDA INGIN HISTORY REVIEW)
        // Ini akan menimpa rating yang ada setiap kali review baru ditambahkan.
        $food->rating = $request->rating;
        $food->save();

        return response()->json(['message' => 'Review added successfully!', 'food' => $food], 201);
    }
}