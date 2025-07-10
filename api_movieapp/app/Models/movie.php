<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

use function PHPSTORM_META\map;

class movie extends Model
{
    use HasFactory;

    protected $fillable = [
        'tmdb_id',
        'title',
        'poster_path',
        'overview',
        'release_date'
    ];

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}
