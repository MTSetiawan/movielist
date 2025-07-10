import 'package:flutter/material.dart';
import 'package:filmin_app/models/movie.dart';
import 'package:filmin_app/screens/movie_detail_screen.dart';

class SeeAllMoviesScreen extends StatefulWidget {
  final String title;
  final String category;
  final List<MovieModel> allMovies;

  const SeeAllMoviesScreen({
    Key? key,
    required this.title,
    required this.category,
    required this.allMovies,
  }) : super(key: key);

  @override
  State<SeeAllMoviesScreen> createState() => _SeeAllMoviesScreenState();
}

class _SeeAllMoviesScreenState extends State<SeeAllMoviesScreen> {
  int currentPage = 1;
  int itemsPerPage = 10;
  List<MovieModel> filteredMovies = [];
  List<MovieModel> currentPageMovies = [];

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
    _filterMovies();
    _updateCurrentPage();
  }

  void _filterMovies() {
    if (widget.category == 'All') {
      filteredMovies = widget.allMovies;
    } else {
      final genreId = genreMap[widget.category];
      filteredMovies = widget.allMovies
          .where((movie) => movie.genreIds.contains(genreId))
          .toList();
    }
  }

  void _updateCurrentPage() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    setState(() {
      currentPageMovies =
          filteredMovies.skip(startIndex).take(itemsPerPage).toList();
    });
  }

  int get totalPages => (filteredMovies.length / itemsPerPage).ceil();

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        currentPage = page;
      });
      _updateCurrentPage();
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      _goToPage(currentPage - 1);
    }
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      _goToPage(currentPage + 1);
    }
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
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Text(
              widget.category,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: filteredMovies.isEmpty
          ? const Center(
              child: Text(
                'No movies found',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : Column(
              children: [
                // Header dengan info total dan pagination
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${filteredMovies.length} movies',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Page $currentPage of $totalPages',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid Movies
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: currentPageMovies.length,
                      itemBuilder: (context, index) {
                        final movie = currentPageMovies[index];
                        final imageUrl = movie.posterPath.isNotEmpty
                            ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                            : '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailScreen(movie: movie),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Movie Poster
                                Expanded(
                                  flex: 4,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey.shade800,
                                                child: const Icon(
                                                  Icons.movie,
                                                  color: Colors.red,
                                                  size: 40,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey.shade800,
                                            child: const Icon(
                                              Icons.movie,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                  ),
                                ),

                                // Movie Info
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              movie.voteAverage
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Pagination Controls
                if (totalPages > 1)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Previous Button
                        GestureDetector(
                          onTap: currentPage > 1 ? _previousPage : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: currentPage > 1
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: currentPage > 1
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              'Previous',
                              style: TextStyle(
                                color:
                                    currentPage > 1 ? Colors.red : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Page Numbers
                        ...List.generate(
                          totalPages > 5 ? 5 : totalPages,
                          (index) {
                            int pageNumber;
                            if (totalPages <= 5) {
                              pageNumber = index + 1;
                            } else {
                              if (currentPage <= 3) {
                                pageNumber = index + 1;
                              } else if (currentPage >= totalPages - 2) {
                                pageNumber = totalPages - 4 + index;
                              } else {
                                pageNumber = currentPage - 2 + index;
                              }
                            }

                            return GestureDetector(
                              onTap: () => _goToPage(pageNumber),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: currentPage == pageNumber
                                      ? Colors.red
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: currentPage == pageNumber
                                        ? Colors.red
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  pageNumber.toString(),
                                  style: TextStyle(
                                    color: currentPage == pageNumber
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 16),

                        // Next Button
                        GestureDetector(
                          onTap: currentPage < totalPages ? _nextPage : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: currentPage < totalPages
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: currentPage < totalPages
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                color: currentPage < totalPages
                                    ? Colors.red
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
