<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminController extends Controller
{ //تسجيل دخول آدمن
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'password' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }
        $admin = User::where('password', $request->password)->first();
        if (!$admin) {
            return response()->json([
                'success' => false,
                'message' => ' كلمة المرور غير صحيحة'
            ], 401);
        }

        $token = $admin->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل الدخول بنجاح',
            'token' => $token,
            'user' => $admin
        ]);
    }



    // عرض طلبات التسجيل المعلقة
    public function pendingRegistrations(Request $request)
    {
        $user = $request->user();

        if (!$user->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بالوصول'
            ], 403);
        }

        $pendingUsers = User::where('status', 'pending')->paginate(10);

        return response()->json([
            'success' => true,
            'users' => $pendingUsers
        ]);
    }

    //الموافقة على مستخدم
    public function approveRegistration(Request $request, $id)
    {
        $user = $request->user();
        if (!$user->isAdmin()) {
            return response()->json([
                'success' => false,
                'massage' => 'غير مصرح لك بالوصول'
            ], 403);
        }

        $targetUser = User::find($id);

        if (!$targetUser) {
            return response()->json([
                'success' => false,
                'message' => 'المستخدم غير موجود'
            ], 404);
        }

        $targetUser->update(['status' => 'approved']);


        return response()->json([
            'success' => true,
            'message' => 'تمت عملية الموافقة على المستخدم'
        ]);
    }

    //رفض مستخدم
    public function rejectRegistration(Request $request, $id)

    {
        $user = $request->user();
        if (!$user->isAdmin()) {
            return response()->json([
                'success' => false,
                'massage' => 'غير مصرح لك بالوصول'
            ], 403);
        }

        $targetUser = User::find($id);

        if (!$targetUser) {
            return response()->json([
                'success' => false,
                'message' => 'المستخدم غير موجود'
            ], 404);
        }

        $targetUser->update(['status' => 'rejected']);


        return response()->json([
            'success' => true,
            'message' => '  تم رفض المستخدم بنجاح'
        ]);
    }
}
