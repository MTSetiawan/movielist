<?php

namespace App\Http\Controllers;

use App\Models\movie;
use App\Models\review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;

class Movies extends Controller
{
    public function popularMovies(Request $request)
    {
        $response = Http::withToken(env('TMDB_BEARER_TOKEN'))
            ->accept('application/json')
            ->get(env('TMDB_BASE_URL') . '/discover/movie', [
                'include_adult' => false,
                'include_video' => false,
                'language' => 'en-US',
                'page' => 1,
                'sort_by' => 'popularity.desc',
            ]);

        if ($response->failed()) {
            return response()->json(['error' => 'Failed to fetch from TMDB'], 500);
        }

        return response()->json($response->json());
    }

    public function detail($id)
    {
        $response = Http::withToken(env('TMDB_BEARER_TOKEN'))
            ->get(env('TMDB_BASE_URL') . "/movie/{$id}", [
                'language' => 'en-US',
            ]);

        if ($response->failed()) {
            return response()->json(['error' => 'Movie not found'], 404);
        }

        return $response->json();
    }

    public function store(Request $request)
    {
        // Cek apakah film sudah ada di database kita
        $movie = movie::where('tmdb_id', $request->tmdb_id)->first();

        // Kalau belum ada, fetch dari TMDb dan simpan
        if (!$movie) {
            $tmdbResponse = Http::withToken(env('TMDB_BEARER_TOKEN'))
                ->accept('application/json')
                ->get(env('TMDB_BASE_URL') . '/discover/movie', [
                    'include_adult' => false,
                    'include_video' => false,
                    'language' => 'en-US',
                    'page' => 1,
                    'sort_by' => 'popularity.desc',
                ]);
            if ($tmdbResponse->failed()) {
                return response()->json(['message' => 'Failed to fetch movie from TMDb.'], 400);
            }

            $data = $tmdbResponse->json();

            $movie = Movie::create([
                'tmdb_id' => $data['id'],
                'title' => $data['title'],
                'poster_path' => $data['poster_path'],
                'overview' => $data['overview'],
                'release_date' => $data['release_date']
            ]);
        }

        // Lalu simpan review
        $review = review::create([
            'user_id' => Auth::id(),
            'movie_id' => $movie->id,
            'review_text' => $request->review_text
        ]);

        return response()->json($review, 201);
    }

    public function searchMovies(Request $request)
    {
        // Ambil query pencarian dari parameter URL
        $query = $request->query('query');
        $page = $request->query('page', 1);

        // Validasi: query tidak boleh kosong
        if (!$query) {
            return response()->json(['error' => 'Search query is required'], 400);
        }

        $response = Http::withToken(env('TMDB_BEARER_TOKEN'))
            ->accept('application/json')
            ->get(env('TMDB_BASE_URL') . '/search/movie', [
                'query' => $query,
                'page' => $page,
                'include_adult' => false,
                'language' => 'en-US',
            ]);

        if ($response->failed()) {
            return response()->json(['error' => 'Failed to fetch from TMDB'], 500);
        }

        return response()->json($response->json());
    }
}
