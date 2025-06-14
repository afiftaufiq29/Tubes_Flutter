<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reservation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ReservationController extends Controller
{
    public function index()
    {
        $reservations = Reservation::all();
        return response()->json($reservations);
    }

    public function show($id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json(['message' => 'Reservation not found'], 404);
        }

        return response()->json($reservation);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'reservation_date' => 'required|date',
            'reservation_time' => 'required|string|max:255',
            'number_of_guests' => 'required|integer|min:1',
            'phone_number' => 'required|string|max:20',
            'special_request' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $reservation = Reservation::create($request->all());
        return response()->json([
            'message' => 'Reservation created successfully',
            'reservation' => $reservation
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json(['message' => 'Reservation not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'reservation_date' => 'sometimes|required|date',
            'reservation_time' => 'sometimes|required|string|max:255',
            'number_of_guests' => 'sometimes|required|integer|min:1',
            'phone_number' => 'sometimes|required|string|max:20',
            'special_request' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $reservation->update($request->all());
        return response()->json([
            'message' => 'Reservation updated successfully',
            'reservation' => $reservation
        ]);
    }

    public function destroy($id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json(['message' => 'Reservation not found'], 404);
        }

        $reservation->delete();
        return response()->json(['message' => 'Reservation deleted successfully']);
    }
}