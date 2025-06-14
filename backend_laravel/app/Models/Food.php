<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Food extends Model
{
    use HasFactory;

    protected $table = 'menu_items';

    protected $casts = [
        'is_available' => 'boolean',
        'price' => 'decimal:2',
        'rating' => 'decimal:1',
    ];

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}