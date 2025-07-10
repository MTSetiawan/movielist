import 'package:filmin_app/screens/favorite_Scree.dart';
import 'package:filmin_app/screens/profile_scree.dart';
import 'package:filmin_app/screens/seeAll_movie_scree.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmin_app/models/movie.dart';
import 'package:filmin_app/service/api_service.dart';
import 'package:filmin_app/screens/movie_detail_screen.dart';
import 'package:filmin_app/screens/search_movie_screen.dart';

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({Key? key}) : super(key: key);

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  late Future<List<MovieModel>> _futureMovies;
  List<MovieModel> _allMovies = [];
  List<MovieModel> _filteredMovies = [];
  String _searchQuery = '';
  String selectedCategory = 'All';
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();

  final Map<String, int> genreMap = {
    'All': 0,
    'Romance': 10749,
    'Action': 28,
    'Horror': 27,
    'Comedy': 35,
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  Future<void> _loadMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    setState(() {
      _futureMovies = ApiService.fetchMovies(token);
    });

    try {
      final movies = await _futureMovies;
      setState(() {
        _allMovies = movies;
        _applyFilters();
      });
    } catch (e) {
      debugPrint('Failed to load movies: $e');
      setState(() {
        _allMovies = [];
        _filteredMovies = [];
      });
    }
  }

  void _applyFilters() {
    List<MovieModel> filtered = _allMovies;

    if (selectedCategory != 'All') {
      filtered = filtered
          .where((movie) => movie.genreIds.contains(genreMap[selectedCategory]))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((movie) => movie.title.toLowerCase().contains(_searchQuery))
          .toList();
    }

    setState(() {
      _filteredMovies = filtered;
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHome() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SearchPage(searchQuery: '')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              height: 48,
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Search Movies...',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Banner
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'FilmIn\nDiscover Amazing Movies',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Genre filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: genreMap.keys.map((category) {
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                      _applyFilters();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.red.shade300
                            : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Movie results
          Expanded(
            child: FutureBuilder<List<MovieModel>>(
              future: _futureMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Failed to load movies',
                        style: TextStyle(color: Colors.white)),
                  );
                }

                if (_filteredMovies.isEmpty) {
                  return const Center(
                    child: Text('No movies found',
                        style: TextStyle(color: Colors.white)),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'Popular Movies',
                        _filteredMovies.take(5).toList(),
                        selectedCategory,
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        'Trending Now',
                        _filteredMovies.skip(5).take(5).toList(),
                        selectedCategory,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<MovieModel> movies, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeeAllMoviesScreen(
                      title: title,
                      category: category,
                      allMovies: _allMovies,
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final imageUrl = movie.posterPath.isNotEmpty
                  ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                  : '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movie: movie)),
                  );
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl,
                                height: 120, fit: BoxFit.cover)
                            : Container(
                                height: 120,
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.movie,
                                    color: Colors.red, size: 40),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = _buildHome();
        break;
      case 1:
        bodyContent = const SearchPage(searchQuery: '');
        break;
      case 2:
        bodyContent = const FavoriteScreen();
        break;
      case 3:
        bodyContent = const UserProfileScreen();
        break;
      default:
        bodyContent = const Center(
          child: Text('Page not implemented',
              style: TextStyle(color: Colors.white)),
        );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: bodyContent),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
