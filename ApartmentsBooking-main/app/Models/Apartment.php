<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Apartment extends Model
{
    use HasFactory;

    protected $fillable = [
        'owner_id',
        'province',
        'city',
        'address',
        'price_per_night',
        'bedrooms',
        'bathroom',
        'maxperson',
        'has_wifi',
        'has_parking',
        'is_available',
    ];

    protected $casts = [
        'has_wifi' => 'boolean',
        'has_parking' => 'boolean',
        'is_available' => 'boolean',
        'price_per_night' => 'decimal:2',
    ];

    // العلاقات
    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    // التوابع المساعدة
    public function isAvailableForDates($checkIn, $checkOut)
    {
        return !$this->bookings()
            ->where(function ($query) use ($checkIn, $checkOut) {
                $query->whereBetween('check_in', [$checkIn, $checkOut])
                    ->orWhereBetween('check_out', [$checkIn, $checkOut])
                    ->orWhere(function ($q) use ($checkIn, $checkOut) {
                        $q->where('check_in', '<=', $checkIn)
                            ->where('check_out', '>=', $checkOut);
                    });
            })
            ->whereIn('status', ['pending', 'approved'])
            ->exists();
    }

    public function averageRating()
    {
        return $this->reviews()->avg('rating');
    }

    public function totalReviews()
    {
        return $this->reviews()->count();
    }
}
