<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('users'); //رقم المستخدم المستأجر الذي قام بالحجز
            $table->foreignId('apartment_id')->constrained('apartments'); //الشقة التي تم حجزها
            $table->date('check-in'); //تاريخ بدء الحجز
            $table->date('check-out'); //تاريخ انتهاء الحجز
            $table->integer('person_number'); //عدد الأشخاص الذين سيقيمون في الشقة
            $table->double('total_price', 10, 2); //السعر الكلي للحجز
            //حالة الحجز (بانتظار الموافقة،تمت الموافقة،الرفض ،تم الالغاء من المستخدم،اكتمل الحجز)
            $table->enum('status', ['pending', 'approved', 'rejected', 'cancelled', 'completed'])->default('pending');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
