<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            FoodTableSeeder::class, // Add this line
            // UserSeeder::class, // If you have a user seeder
        ]);
    }
}