<?php

use App\Http\Controllers\AdminController;
use App\Http\Controllers\ApartmentController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProfileController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

//المسارات العامة
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);
//المسارات التي تحتاج لمصادقة
//المستخدم
Route::get('user', [AuthController::class, 'user'])->middleware('auth:sanctum');
Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');

//الملف الشخصي
Route::put('profile', [ProfileController::class, 'update'])->middleware('auth:sanctum');

//الشقق
//إضافة شقة من قبل المالك فقط
Route::post('addApartment', [ApartmentController::class, 'store'])->middleware('auth:sanctum');
//عرض جميع الشقق مع مواصفاتها للمستخدمين
Route::get('indexApartment', [ApartmentController::class, 'index'])->middleware('auth:sanctum');
//فلترة شقق للمستأجر
Route::get('ApartmentsFilter', [ApartmentController::class, 'indexfilter'])->middleware('auth:sanctum');

//الآدمن
//تسجيل دخول آدمن
Route::post('loginAdmin', [AdminController::class, 'login']);
//عرض طلبات التسجيل المعلقة
Route::get('pending-registers', [AdminController::class, 'pendingRegistrations'])->middleware('auth:sanctum');
//قبول مستخدم
Route::post('approve-register/{id}', [AdminController::class, 'approveRegistration'])->middleware('auth:sanctum');
//رفض مستخدم
Route::post('reject-register/{id}', [AdminController::class, 'rejectRegistration'])->middleware('auth:sanctum');
