<?php

use App\Http\Controllers\CommentController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\Movies;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('register', [UserController::class, 'register']);
Route::post('login', [UserController::class, 'login']);
Route::middleware('auth:sanctum')->get('/profile', [UserController::class, 'profile']);

Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/movies/popular', [Movies::class, 'popularMovies']);
    Route::get('/movies/{id}', [Movies::class, 'detail']);
    Route::post('/movies', [Movies::class, 'store']);
    Route::get('/search-movies', [Movies::class, 'searchMovies']);
});

Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/movies/{movieId}/comments', [CommentController::class, 'index']);
    Route::post('/movies/{movieId}/comments', [CommentController::class, 'store']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/favorites/{movieId}', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{movieId}', [FavoriteController::class, 'destroy']);
    Route::get('/favorites', [FavoriteController::class, 'index']);
});
