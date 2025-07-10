<?php

namespace App\Http\Controllers;

use App\Models\favorite;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();

        $favorite = favorite::where('user_id', $user->id)
            ->pluck('movie_id');
        return response()->json($favorite, 200);
    }

    public function store($movieId)
    {
        $user = Auth::user();

        $exists = favorite::where('user_id', $user->id)
            ->where('movie_id', $movieId)
            ->exists();

        if ($exists) {
            return response()->json([
                'message' => 'Movie already in favorites'
            ], 400);
        }

        $favorite = favorite::create([
            'user_id' => $user->id,
            'movie_id' => $movieId,
        ]);

        return response()->json($favorite, 201);
    }


    public function destroy($movieId)
    {
        $user = Auth::user();

        $delete = favorite::where('user_id', $user->id)
            ->where('movie_id', $movieId)
            ->delete();

        if ($delete) {
            return response()->json(['message' => 'Removed from favorites']);
        }

        return response()->json(['message' => 'Not found']);
    }
}
