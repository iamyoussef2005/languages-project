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
        Schema::create('apartments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users'); //ربط الشقة بصاحبها
            $table->string('province'); //محافظة
            $table->string('city'); //مدينة
            $table->text('address'); //عنوان الكامل
            $table->integer('bedrooms'); //عدد غرف النوم
            $table->integer('bathroom'); //عدد الحمامات
            $table->integer('maxperson'); //العدد المسموح به للاشخاص الذين سوف يستأجرون
            $table->double('price_per_night', 10, 2); //سعر الايجار لكل ليلة
            $table->boolean('has_parking')->default(false); //متوفر حديقة أم لا
            $table->boolean('has_wifi')->default(false); //متوفر انترنت أم لا
            $table->boolean('is_available')->default(true); //حالة التوفر
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('apartments');
    }
};
