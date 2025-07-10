import 'package:flutter/material.dart';
import 'package:filmin_app/models/movie.dart';
import 'package:filmin_app/service/api_service.dart';
import 'package:filmin_app/screens/movie_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<MovieModel>> _futureFavoriteMovies;

  @override
  void initState() {
    super.initState();
    _futureFavoriteMovies = _loadFavorites();
  }

  Future<List<MovieModel>> _loadFavorites() async {
    final token = await ApiService.getToken();
    final allMovies = await ApiService.fetchMovies(token!);
    final favoriteIds = await ApiService.fetchFavorites();

    // Cocokkan id dari daftar favorit
    return allMovies.where((movie) => favoriteIds.contains(movie.id)).toList();
  }

  Future<void> _removeFavorite(MovieModel movie) async {
    // Add your remove favorite API call here
    // await ApiService.removeFavorite(movie.id);

    setState(() {
      _futureFavoriteMovies = _loadFavorites();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${movie.title} removed from favorites'),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add search functionality
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MovieModel>>(
        future: _futureFavoriteMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD32F2F),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load favorites',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureFavoriteMovies = _loadFavorites();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.favorite_outline,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Favorite Movies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start adding movies to your favorites\nto see them here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Browse Movies',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final movies = snapshot.data!;
          return Column(
            children: [
              // Header with count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Text(
                  '${movies.length} Movie${movies.length != 1 ? 's' : ''} in Favorites',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Movies List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return _buildMovieCard(movie);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMovieCard(MovieModel movie) {
    final imageUrl = movie.posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Movie Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 120,
                  color: const Color(0xFF2A2A2A),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: const Color(0xFF2A2A2A),
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white24,
                              size: 32,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.movie,
                          color: Colors.white24,
                          size: 32,
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Movie Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      movie.releaseDate,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Overview (first 2 lines)
                    Text(
                      movie.overview,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action Buttons
              Column(
                children: [
                  // Remove from favorites
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => _removeFavorite(movie),
                      icon: const Icon(
                        Icons.favorite,
                        color: Color(0xFFD32F2F),
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // More options
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showOptionsBottomSheet(movie);
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(MovieModel movie) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildBottomSheetOption(
              icon: Icons.play_arrow,
              title: 'Watch Now',
              onTap: () {
                Navigator.pop(context);
                // Handle watch action
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.download,
              title: 'Download',
              onTap: () {
                Navigator.pop(context);
                // Handle download action
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.share,
              title: 'Share',
              onTap: () {
                Navigator.pop(context);
                // Handle share action
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.favorite_border,
              title: 'Remove from Favorites',
              onTap: () {
                Navigator.pop(context);
                _removeFavorite(movie);
              },
              isDestructive: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? const Color(0xFFD32F2F) : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isDestructive ? const Color(0xFFD32F2F) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
