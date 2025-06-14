<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MenuItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'price',
        'image_url',
        'type',
        'is_available',
        'rating',
    ];

    // Tambahkan ini untuk melakukan casting otomatis
    protected $casts = [
        'price' => 'float', // Pastikan harga dikonversi ke float (double di PHP)
        'rating' => 'float', // Pastikan rating dikonversi ke float
        'is_available' => 'boolean', // Ini juga baik untuk konsistensi
    ];

    // Jika Anda akan mengimplementasikan reviews dengan tabel terpisah,
    // maka relasi 'reviews' harus didefinisikan di sini.
    /*
    public function reviews()
    {
        return $this->hasMany(Review::class); // Ganti Review::class dengan nama model Review Anda
    }
    */
}