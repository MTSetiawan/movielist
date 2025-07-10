<?php

namespace App\Http\Controllers;

use App\Models\movie;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MovieController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $movie = movie::all();
        return response()->json(['menu' => $movie], 200);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => "required|string|max:255",
            'genre' => 'required|string',
            'release_date' => 'required|date',
            'trailer' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'director' => 'required|string',
        ]);

        $movie = movie::create($request->all());
        return response()->json(['message' => 'Movie created successfully', 'movie' => $movie], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(movie $movie)
    {
        $movie = movie::with('reviews')->findOrFail($movie);
        return response()->json($movie);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(movie $movie)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, movie $movie)
    {
        $movie = Movie::findOrFail($movie);
        $movie->update($request->only(['title', 'genre', 'release_date', 'director', 'trailer']));
        return response()->json($movie);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(movie $movie)
    {
        $movie = Movie::findOrFail($movie);
        $movie->delete();
        return response()->json(['message' => 'Movie deleted']);
    }
}
