<?php

namespace App\Http\Controllers;

use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users',
            'birth_date' => 'required|date',
            'personal_photo' => 'required|image|mimes:png,jpg,gif|max:2048',
            'id_photo' => 'required|image|mimes:png,jpg,gif|max:2048',
            'role' => 'required|in:tenant,owner',
            'password' => 'required|string|min:8|unique:users'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }
        $personalphotopath = $request->file('personal_photo')->store('personal_photos', 'public');
        $idphotopath = $request->file('id_photo')->store('id_photos', 'public');

        $user = User::create([
            'first_name' => $request->first_name,
            'last_name' => $request->last_name,
            'phone' => $request->phone,
            'birth_date' => Carbon::parse($request->birth_date)->format('Y-m-d'),
            'personal_photo' => $personalphotopath,
            'id_photo' => $idphotopath,
            'role' => $request->role,
            'password' => $request->password,
            'status' => 'pending', 
        ]);
        return response()->json([
            'success' => true,
            'message' => 'Registration successful please wait for admin approval',
            'user' => $user
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|string',
            'password' => 'required|string',

        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('phone', $request->phone)->first();

        if (!$user || ($request->password !== $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Phone number or password is incorrect'
            ], 401);
        }


        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Logged in successfully',
            'token' => $token,
            'user' => $user
        ]);
    }
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ]);
    }

    public function user(Request $request) 
    {

        return response()->json([
            'success' => true,
            'user' => $request->user()

        ]);
    }
}
