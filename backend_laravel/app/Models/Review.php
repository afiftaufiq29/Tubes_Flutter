<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'food_id',
        'rating',
        'comment',
        'date',
    ];

    protected $casts = [
        'date' => 'date',
        'rating' => 'integer',
    ];

    public function food()
    {
        return $this->belongsTo(Food::class);
    }
}