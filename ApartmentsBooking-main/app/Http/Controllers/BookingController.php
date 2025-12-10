<?php

namespace App\Http\Controllers;

use App\Models\Apartment;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;



class BookingController extends Controller
{
    // إنشاء حجز جديد
    public function store(Request $request)
    {
        $user = $request->user();

        if (!$user->isTenant()) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بإجراء حجز'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'apartment_id' => 'required|exists:apartments,id',
            'check_in' => 'required|date|after:today',
            'check_out' => 'required|date|after:check_in',
            'guests_count' => 'required|integer|min:1',
            'special_requests' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $apartment = Apartment::find($request->apartment_id);

        // التحقق من توفر الشقة للفترة المطلوبة
        if (!$apartment->isAvailableForDates($request->check_in, $request->check_out)) {
            return response()->json([
                'success' => false,
                'message' => 'الشقة غير متاحة للفترة المطلوبة'
            ], 422);
        }

        // التحقق من عدد الضيوف
        if ($request->guests_count > $apartment->max_guests) {
            return response()->json([
                'success' => false,
                'message' => 'عدد الضيوف يتجاوز السعة القصوى للشقة'
            ], 422);
        }

        // حساب السعر الإجمالي
        $nights = date_diff(
            date_create($request->check_in),
            date_create($request->check_out)
        )->days;

        $totalPrice = $nights * $apartment->price_per_night;

        $booking = Booking::create([
            'tenant_id' => $user->id,
            'apartment_id' => $apartment->id,
            'check_in' => $request->check_in,
            'check_out' => $request->check_out,
            'guests_count' => $request->guests_count,
            'total_price' => $totalPrice,
            'special_requests' => $request->special_requests,
            'status' => 'pending', // يحتاج موافقة صاحب الشقة
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم إنشاء الحجز بنجاح، في انتظار موافقة صاحب الشقة',
            'booking' => $booking->load('apartment')
        ], 201);
    }

    // عرض جميع حجوزات المستخدم
    public function index(Request $request)
    {
        $user = $request->user();

        $bookings = Booking::with('apartment')
            ->where('tenant_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'success' => true,
            'bookings' => $bookings
        ]);
    }

    // تعديل الحجز
    public function update(Request $request, $id)
    {
        $user = $request->user();
        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'الحجز غير موجود'
            ], 404);
        }

        if ($booking->tenant_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بتعديل هذا الحجز'
            ], 403);
        }

        if (!$booking->canBeModified()) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن تعديل هذا الحجز'
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'check_in' => 'required|date|after:today',
            'check_out' => 'required|date|after:check_in',
            'guests_count' => 'required|integer|min:1',
            'special_requests' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        // التحقق من توفر الشقة للفترة الجديدة
        $apartment = $booking->apartment;
        if (!$apartment->isAvailableForDates($request->check_in, $request->check_out, $booking->id)) {
            return response()->json([
                'success' => false,
                'message' => 'الشقة غير متاحة للفترة المطلوبة'
            ], 422);
        }

        // التحقق من عدد الضيوف
        if ($request->guests_count > $apartment->max_guests) {
            return response()->json([
                'success' => false,
                'message' => 'عدد الضيوف يتجاوز السعة القصوى للشقة'
            ], 422);
        }

        // حساب السعر الإجمالي الجديد
        $nights = date_diff(
            date_create($request->check_in),
            date_create($request->check_out)
        )->days;

        $totalPrice = $nights * $apartment->price_per_night;

        $booking->update([
            'check_in' => $request->check_in,
            'check_out' => $request->check_out,
            'guests_count' => $request->guests_count,
            'total_price' => $totalPrice,
            'special_requests' => $request->special_requests,
            'status' => 'pending', // يعود للحالة pending لموافقة صاحب الشقة
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم تعديل الحجز بنجاح، في انتظار موافقة صاحب الشقة',
            'booking' => $booking->fresh()
        ]);
    }

    // إلغاء الحجز
    public function cancel(Request $request, $id)
    {
        $user = $request->user();
        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'الحجز غير موجود'
            ], 404);
        }

        if ($booking->tenant_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بإلغاء هذا الحجز'
            ], 403);
        }

        if (!$booking->canBeCancelled()) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن إلغاء هذا الحجز'
            ], 422);
        }

        $booking->update(['status' => 'cancelled']);

        return response()->json([
            'success' => true,
            'message' => 'تم إلغاء الحجز بنجاح'
        ]);
    }
}
