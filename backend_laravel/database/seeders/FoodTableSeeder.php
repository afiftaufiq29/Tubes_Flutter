<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Food; // Adjust if your model is named differently

class FoodTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Food::create([
            'name' => 'Nasi Goreng',
            'description' => 'Nasi goreng spesial dengan telur dan ayam.',
            'price' => 25000,
            'image_url' => 'assets/images/nasi_goreng.jpg', // This should be a URL if served, or handle asset paths in Flutter
            'is_available' => true,
            'rating' => 4.5,
        ]);

        Food::create([
            'name' => 'Mie Ayam',
            'description' => 'Mie dengan potongan ayam dan pangsit.',
            'price' => 20000,
            'image_url' => 'assets/images/mie_ayam.jpg',
            'is_available' => true,
            'rating' => 4.2,
        ]);

        Food::create([
            'name' => 'Es Teh Manis',
            'description' => 'Teh manis dingin menyegarkan.',
            'price' => 8000,
            'image_url' => 'assets/images/es_teh.jpg',
            'is_available' => true,
            'rating' => 4.0,
        ]);

        Food::create([
            'name' => 'Jus Alpukat',
            'description' => 'Jus alpukat murni dengan susu coklat.',
            'price' => 15000,
            'image_url' => 'assets/images/jus_alpukat.jpg',
            'is_available' => true,
            'rating' => 4.7,
        ]);
        // Add more food and drink items as needed
    }
}