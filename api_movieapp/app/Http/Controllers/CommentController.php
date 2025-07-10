<?php

namespace App\Http\Controllers;

use App\Models\comment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CommentController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index($movieId)
    {
        $comment = comment::with('user')->where('movie_id', $movieId)->latest()->get();

        return response()->json($comment);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request, $movieId)
    {

        $request->validate([
            'content' => 'required|string|max:255',
        ]);

        $comment = comment::create([
            'user_id' => Auth::id(), // ambil user_id dari token
            'movie_id' => $movieId,
            'content' => $request->content,
        ]);

        return response()->json($comment, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(comment $comment)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(comment $comment)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, comment $comment)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(comment $comment)
    {
        //
    }
}
