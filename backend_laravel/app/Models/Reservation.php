<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Reservation extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'reservation_date',
        'reservation_time',
        'number_of_guests',
        'phone_number',
        'special_request',
    ];

    protected $casts = [
        'reservation_date' => 'date',
        'number_of_guests' => 'integer',
    ];
}