<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ReviewController extends Controller
{
    // إضافة تقييم
    public function store(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'booking_id' => 'required|exists:bookings,id',
            'rating' => 'required|integer|between:1,5',
            'comment' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $booking = Booking::find($request->booking_id);

        // التحقق من أن الحجز للمستخدم
        if ($booking->tenant_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بتقييم هذا الحجز'
            ], 403);
        }

        // التحقق من أن الحجز مكتمل
        if ($booking->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'يمكن التقييم فقط للحجوزات المكتملة'
            ], 422);
        }

        // التحقق من عدم وجود تقييم سابق
        if ($booking->review) {
            return response()->json([
                'success' => false,
                'message' => 'لقد قمت بتقييم هذا الحجز مسبقاً'
            ], 422);
        }

        $review = Review::create([
            'booking_id' => $booking->id,
            'tenant_id' => $user->id,
            'apartment_id' => $booking->apartment_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم إضافة التقييم بنجاح',
            'review' => $review
        ], 201);
    }
}
