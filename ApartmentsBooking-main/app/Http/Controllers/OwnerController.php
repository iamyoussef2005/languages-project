<?php

namespace App\Http\Controllers;

use App\Models\Apartment;
use App\Models\Booking;
use Illuminate\Http\Request;

class OwnerController extends Controller
{
    // عرض حجوزات شقق المالك
    public function bookings(Request $request)
    {
        $user = $request->user();

        if (!$user->isOwner()) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بالوصول'
            ], 403);
        }

        $bookings = Booking::with(['apartment', 'tenant'])
            ->whereHas('apartment', function ($query) use ($user) {
                $query->where('owner_id', $user->id);
            })
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'success' => true,
            'bookings' => $bookings
        ]);
    }

    // الموافقة على حجز
    public function approveBooking(Request $request, $id)
    {
        $user = $request->user();
        $booking = Booking::with('apartment')->find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'الحجز غير موجود'
            ], 404);
        }

        if ($booking->apartment->owner_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بالموافقة على هذا الحجز'
            ], 403);
        }

        $booking->update(['status' => 'approved']);

        return response()->json([
            'success' => true,
            'message' => 'تم الموافقة على الحجز بنجاح'
        ]);
    }

    // رفض حجز
    public function rejectBooking(Request $request, $id)
    {
        $user = $request->user();
        $booking = Booking::with('apartment')->find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'الحجز غير موجود'
            ], 404);
        }

        if ($booking->apartment->owner_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك برفض هذا الحجز'
            ], 403);
        }

        $booking->update(['status' => 'rejected']);

        return response()->json([
            'success' => true,
            'message' => 'تم رفض الحجز بنجاح'
        ]);
    }

    // شقق المالك
    public function apartments(Request $request)
    {
        $user = $request->user();

        if (!$user->isOwner()) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بالوصول'
            ], 403);
        }

        $apartments = Apartment::where('owner_id', $user->id)->paginate(10);

        return response()->json([
            'success' => true,
            'apartments' => $apartments
        ]);
    }
}
