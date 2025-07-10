<?php

namespace App\Http\Controllers;

use App\Models\review;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function index()
    {
        $reviews = Review::with(['user', 'movie'])->get();
        return response()->json($reviews);
    }

    public function store(Request $request)
    {
        $request->validate([
            'movie_id' => 'required|exists:movies,id',
            'rating' => 'required|string',
            'review_text' => 'nullable|string'
        ]);

        $review = Review::create([
            'user_id' => Auth::id(), // ambil user_id dari token
            'movie_id' => $request->movie_id,
            'rating' => $request->rating,
            'review_text' => $request->review_text
        ]);


        return response()->json($review, 201);
    }

    public function show($id)
    {
        $review = Review::with(['user', 'movie'])->findOrFail($id);
        return response()->json($review);
    }

    public function update(Request $request, $id)
    {
        $review = Review::findOrFail($id);

        // Cek apakah user yang login adalah pemilik review
        if ($review->user_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'rating' => 'sometimes|required|string',
            'review_text' => 'nullable|string'
        ]);

        $review->update($request->only('rating', 'review_text'));

        return response()->json($review);
    }


    public function destroy($id)
    {
        $review = Review::findOrFail($id);

        if ($review->user_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $review->delete();

        return response()->json(['message' => 'Review deleted successfully.']);
    }
}
