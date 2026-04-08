import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/models/movie_content.dart';
import '../../core/providers/movie_content_provider.dart';
import '../movie_details/movie_details_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieContentProvider>().loadGenres();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Categories',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MovieContentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingGenres && provider.genres.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.genres.length,
            itemBuilder: (context, index) {
              final genre = provider.genres[index];
              return _GenreCard(
                genre: genre,
                index: index,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  final Genre genre;
  final int index;
  final bool isDark;

  const _GenreCard({
    required this.genre,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
      [const Color(0xFF14B8A6), const Color(0xFF06B6D4)],
      [const Color(0xFFF97316), const Color(0xFFEAB308)],
      [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
    ];

    final colorPair = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenreMoviesPage(genre: genre),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colorPair,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorPair[0].withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                _getGenreIcon(genre.name),
                size: 80,
                color: Colors.white.withAlpha(51),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getGenreIcon(genre.name),
                    color: Colors.white,
                    size: 28,
                  ),
                  const Spacer(),
                  Text(
                    genre.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGenreIcon(String genreName) {
    switch (genreName.toLowerCase()) {
      case 'action':
        return Iconsax.flash;
      case 'adventure':
        return Iconsax.map;
      case 'animation':
        return Iconsax.magic_star;
      case 'comedy':
        return Iconsax.emoji_happy;
      case 'crime':
        return Iconsax.security_user;
      case 'documentary':
        return Iconsax.video_play;
      case 'drama':
        return Iconsax.mask;
      case 'family':
        return Iconsax.people;
      case 'fantasy':
        return Iconsax.magicpen;
      case 'history':
        return Iconsax.book;
      case 'horror':
        return Iconsax.ghost;
      case 'music':
        return Iconsax.music;
      case 'mystery':
        return Iconsax.search_normal;
      case 'romance':
        return Iconsax.heart;
      case 'science fiction':
        return Iconsax.cpu;
      case 'tv movie':
        return Iconsax.monitor;
      case 'thriller':
        return Iconsax.warning_2;
      case 'war':
        return Iconsax.flag;
      case 'western':
        return Iconsax.sun_1;
      default:
        return Iconsax.video;
    }
  }
}

class GenreMoviesPage extends StatefulWidget {
  final Genre genre;

  const GenreMoviesPage({
    super.key,
    required this.genre,
  });

  @override
  State<GenreMoviesPage> createState() => _GenreMoviesPageState();
}

class _GenreMoviesPageState extends State<GenreMoviesPage> {
  List<MovieContent> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    final provider = context.read<MovieContentProvider>();
    _movies = await provider.getMoviesByGenre(widget.genre.id);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.genre.name,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movies.isEmpty
              ? _buildEmptyState(isDark)
              : RefreshIndicator(
                  onRefresh: _loadMovies,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _movies.length,
                    itemBuilder: (context, index) {
                      return _MovieCard(
                        movie: _movies[index],
                        isDark: isDark,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.video_slash,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No movies found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieContent movie;
  final bool isDark;

  const _MovieCard({
    required this.movie,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsPage(
              movieId: movie.id,
              movie: movie,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: movie.posterUrl.isNotEmpty
                        ? Image.network(
                            movie.posterUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Iconsax.video,
                                  color: Colors.grey.shade500,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Iconsax.video,
                              color: Colors.grey.shade500,
                            ),
                          ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(179),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Watchlist button
                Positioned(
                  top: 8,
                  left: 8,
                  child: Consumer<MovieContentProvider>(
                    builder: (context, provider, _) {
                      final isInWatchlist = provider.isInWatchlist(movie.id);
                      return GestureDetector(
                        onTap: () {
                          provider.toggleWatchlist(movie.id, movie: movie);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(128),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isInWatchlist ? Icons.favorite : Icons.favorite_border,
                            color: isInWatchlist ? Colors.red : Colors.white,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${movie.releaseYear} • ${movie.formattedRuntime}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
