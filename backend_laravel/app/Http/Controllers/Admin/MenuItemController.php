<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MenuItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon; // Tambahkan ini untuk tanggal

class MenuItemController extends Controller
{
    /**
     * Display a listing of the resource. (Untuk Web Admin UI)
     */
    public function index()
    {
        $menuItems = MenuItem::orderBy('type')->orderBy('name')->paginate(10);
        return view('admin.menu_items.index', compact('menuItems'));
    }

    /**
     * Show the form for creating a new resource. (Untuk Web Admin UI)
     */
    public function create()
    {
        return view('admin.menu_items.create');
    }

    /**
     * Store a newly created resource in storage. (Untuk Web Admin UI)
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', // Max 2MB
            'type' => 'required|in:food,drink',
            'is_available' => 'boolean',
            'rating' => 'numeric|min:0|max:5',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $data = $request->except('image'); // Exclude image from fillable data
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('menu_images', 'public');
            $data['image_url'] = Storage::url($imagePath);
        }

        MenuItem::create($data);

        return redirect()->route('admin.menu_items.index')->with('success', 'Menu item created successfully!');
    }

    /**
     * Display the specified resource. (Untuk Web Admin UI - opsional)
     */
    public function show(MenuItem $menuItem)
    {
        return view('admin.menu_items.show', compact('menuItem'));
    }

    /**
     * Show the form for editing the specified resource. (Untuk Web Admin UI)
     */
    public function edit(MenuItem $menuItem)
    {
        return view('admin.menu_items.edit', compact('menuItem'));
    }

    /**
     * Update the specified resource in storage. (Untuk Web Admin UI)
     */
    public function update(Request $request, MenuItem $menuItem)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', // Max 2MB
            'type' => 'required|in:food,drink',
            'is_available' => 'boolean',
            'rating' => 'numeric|min:0|max:5',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $data = $request->except('image'); // Exclude image from fillable data
        if ($request->hasFile('image')) {
            // Delete old image if exists
            if ($menuItem->image_url) {
                Storage::disk('public')->delete(str_replace('/storage/', '', $menuItem->image_url));
            }
            $imagePath = $request->file('image')->store('menu_images', 'public');
            $data['image_url'] = Storage::url($imagePath);
        }

        $menuItem->update($data);

        return redirect()->route('admin.menu_items.index')->with('success', 'Menu item updated successfully!');
    }

    /**
     * Remove the specified resource from storage. (Untuk Web Admin UI)
     */
    public function destroy(MenuItem $menuItem)
    {
        if ($menuItem->image_url) {
            Storage::disk('public')->delete(str_replace('/storage/', '', $menuItem->image_url));
        }
        $menuItem->delete();
        return redirect()->route('admin.menu_items.index')->with('success', 'Menu item deleted successfully!');
    }

    // API endpoints untuk Flutter app (ini digunakan oleh Flutter untuk GET daftar makanan/minuman)
    // Note: getFoodItems() ini bisa saja diganti atau dihapus jika /api/foods (FoodController::index) sudah cukup
    // Namun, sesuai rute api.php Anda, ini digunakan oleh rute `/foods-admin`
    public function getFoodItems()
    {
        $foods = MenuItem::where('type', 'food')->where('is_available', true)->get();
        $foods->each(function ($food) {
            $food->reviews = []; // Berikan array kosong untuk reviews di setiap item untuk kompatibilitas Flutter
        });
        return response()->json($foods);
    }

    public function getDrinkItems()
    {
        $drinks = MenuItem::where('type', 'drink')->where('is_available', true)->get();
        $drinks->each(function ($drink) {
            $drink->reviews = []; // Berikan array kosong untuk reviews di setiap item untuk kompatibilitas Flutter
        });
        return response()->json($drinks);
    }

    // Perhatikan: Method addReview sebelumnya ada di sini,
    // tetapi sudah dipindahkan ke FoodController::addReview sesuai routes/api.php Anda.
    // Jika tidak ada rute yang memanggil method ini di MenuItemController, maka ini tidak perlu.
}