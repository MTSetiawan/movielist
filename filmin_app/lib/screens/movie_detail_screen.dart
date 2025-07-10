import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmin_app/models/movie.dart';
import 'package:filmin_app/models/comment.dart';
import 'package:filmin_app/service/api_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<List<Comment>> _futureComments;
  final TextEditingController _commentController = TextEditingController();
  String token = '';
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadTokenAndComments();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final favorites = await ApiService.fetchFavorites();
    setState(() {
      isBookmarked = favorites.contains(widget.movie.id);
    });
  }

  Future<void> _loadTokenAndComments() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    _loadComments();
  }

  void _loadComments() {
    setState(() {
      _futureComments = ApiService.fetchComments(widget.movie.id, token);
    });
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      await ApiService.postComment(widget.movie.id, content, token);
      _commentController.clear();
      _loadComments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Comment posted successfully!'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to post comment'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.movie.posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}'
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Movie Poster
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0A),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color:
                        isBookmarked ? const Color(0xFFD32F2F) : Colors.white,
                  ),
                  onPressed: () async {
                    setState(() => isBookmarked = !isBookmarked);
                    try {
                      if (isBookmarked) {
                        await ApiService.addFavorite(widget.movie.id);
                      } else {
                        await ApiService.removeFavorite(widget.movie.id);
                      }
                    } catch (e) {
                      setState(() => isBookmarked = !isBookmarked); // rollback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update favorite')),
                      );
                    }
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1A1A1A),
                        child: const Icon(
                          Icons.movie,
                          size: 100,
                          color: Colors.white24,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: const Color(0xFF1A1A1A),
                      child: const Icon(
                        Icons.movie,
                        size: 100,
                        color: Colors.white24,
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          const Color(0xFF0A0A0A),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Movie Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Title
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Movie Info Row
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Release Date
                      Text(
                        widget.movie.releaseDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Play Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle play action
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        'Play',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.thumb_up_outlined,
                          label: 'Like',
                          count: '2.5k',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.visibility_outlined,
                          label: 'Views',
                          count: '12k',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.download_outlined,
                          label: 'Download',
                          count: '',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Overview Section
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.movie.overview,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Comments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // View all comments
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Comment Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.white, size: 20),
                            onPressed: _postComment,
                          ),
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Comments List
                  FutureBuilder<List<Comment>>(
                    future: _futureComments,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFD32F2F),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Failed to load comments',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'No comments yet. Be the first to comment!',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final comments = snapshot.data!;
                      return Column(
                        children: comments
                            .map((comment) => _buildCommentTile(comment))
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (count.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              count,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFD32F2F),
                child: Text(
                  comment.username.isNotEmpty
                      ? comment.username[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Just now', // You can add timestamp to Comment model
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
