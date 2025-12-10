<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;


class ProfileController extends Controller
{
    // تحديث الملف الشخصي
    public function update(Request $request)
    {

            $user = $request->user();

            $validator = Validator::make($request->all(), [
                'first_name' => 'required|string|max:255',
                'last_name' => 'required|string|max:255',
                'birth_date' => 'required|date',
                'personal_photo' => 'sometimes|image|max:2048|mimes:png,jpg,gif',
                'id_photo' => 'sometimes|image|max:2048|mimes:png,jpg,gif',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'errors' => $validator->errors()
                ], 422);
            }

            $data = $request->only(['first_name', 'last_name', 'birth_date']);

            // معالجة صورة الملف الشخصي
            if ($request->hasFile('personal_photo')) {
                if ($user->personal_photo) {
                    Storage::delete($user->personal_photo);
                }
                $data['personal_photo'] = $request->file('personal_photo')
                    ->store('personal_photo','public');
            }

            // معالجة صورة الهوية
            if ($request->hasFile('id_photo')) {
                if ($user->id_photo) {
                    Storage::delete($user->id_photo);
                }
                $data['id_photo'] = $request->file('id_photo')
                    ->store('id_photo','public');
            }

            $user->update($data);

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث الملف الشخصي بنجاح',
                'user' => $user->fresh()
            ]);

    }
}
