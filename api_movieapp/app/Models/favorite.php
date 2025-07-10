<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class favorite extends Model
{
    protected $fillable = [
        'user_id',
        'movie_id',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
