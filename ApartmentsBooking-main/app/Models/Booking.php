<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{

    use HasFactory;

    protected $fillable = [
        'tenant_id',
        'apartment_id',
        'check_in',
        'check_out',
        'person_number',
        'total_price',
        'status',

    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'total_price' => 'decimal:2',
    ];

    // العلاقات
    public function tenant()
    {
        return $this->belongsTo(User::class, 'tenant_id');
    }

    public function apartment()
    {
        return $this->belongsTo(Apartment::class);
    }

    public function review()
    {
        return $this->hasOne(Review::class);
    }

    // التوابع المساعدة
    public function canBeCancelled()
    {
        return in_array($this->status, ['pending', 'approved']) &&
            $this->check_in > now()->addDays(1);
    }

    public function canBeModified()
    {
        return $this->status === 'pending';
    }

    public function calculateTotalPrice()
    {
        $nights = $this->check_in->diffInDays($this->check_out);
        return $nights * $this->apartment->price_per_night;
    }
}
