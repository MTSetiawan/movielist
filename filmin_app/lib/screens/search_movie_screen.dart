import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmin_app/models/movie.dart';
import 'package:filmin_app/service/api_service.dart';
import 'package:filmin_app/screens/movie_detail_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required String searchQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Future<List<MovieModel>>? _searchResults;
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    setState(() {
      _searchResults = ApiService.searchMovies(query, token);
    });

    _animationController.forward();

    // Reset loading state after search completes
    _searchResults?.then((_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = null;
      _isSearching = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Movies',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.red.shade900.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade900.withOpacity(0.2),
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onSubmitted: (_) => _performSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search for movies, actors, genres...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.red.shade600,
                        size: 24,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.red.shade400,
                              ),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Search Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade800],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade600.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSearching ? null : _performSearch,
                      child: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'SEARCH MOVIES',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: _searchResults == null
                ? _buildEmptyState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: FutureBuilder<List<MovieModel>>(
                      future: _searchResults,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoadingState();
                        }

                        if (snapshot.hasError) {
                          return _buildErrorState();
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildNoResultsState();
                        }

                        final movies = snapshot.data!;
                        return _buildResultsList(movies);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.movie_filter,
              size: 64,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Discover Amazing Movies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for your favorite movies,\nactors, or genres',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
          ),
          const SizedBox(height: 16),
          const Text(
            'Searching movies...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade600),
          const SizedBox(height: 16),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.red.shade600),
          const SizedBox(height: 16),
          const Text(
            'No Results Found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<MovieModel> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Found ${movies.length} results',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final imageUrl = movie.posterPath.isNotEmpty
                  ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.2),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade800,
                                  child: Icon(
                                    Icons.movie,
                                    color: Colors.red.shade600,
                                    size: 30,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade800,
                              child: Icon(
                                Icons.movie,
                                color: Colors.red.shade600,
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                  title: Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            movie.releaseDate.isNotEmpty
                                ? movie.releaseDate.substring(0, 4)
                                : 'N/A',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.overview.isNotEmpty
                            ? movie.overview.length > 100
                                ? '${movie.overview.substring(0, 100)}...'
                                : movie.overview
                            : 'No description available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.red.shade600,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
