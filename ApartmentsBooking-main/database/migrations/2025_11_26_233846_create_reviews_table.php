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
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained('bookings'); //الحجز الذي يقيّمه المستأجر
            $table->foreignId('tenant_id')->constrained('users'); //المستأجر الذي يقيّم
            $table->foreignId('apartment_id')->constrained('apartments'); //الشقة التي تم تقييمها
            $table->integer('rating')->between(1, 5); //تقييم من 1 الى 5
            $table->text('comment')->nullable(); //التعليق الذي يكتبه المستأجر عن تجربته
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
