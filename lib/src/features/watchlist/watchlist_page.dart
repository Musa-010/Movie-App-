import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/models/movie_content.dart';
import '../../core/providers/movie_content_provider.dart';
import '../movie_details/movie_details_page.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieContentProvider>().loadWatchlist();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          'My List',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF006BF3),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF006BF3),
          tabs: const [
            Tab(text: 'Watchlist'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _WatchlistTab(isDark: isDark),
          _FavoritesTab(isDark: isDark),
        ],
      ),
    );
  }
}

class _WatchlistTab extends StatelessWidget {
  final bool isDark;

  const _WatchlistTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieContentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingWatchlist) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.watchlist.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadWatchlist(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.watchlist.length,
            itemBuilder: (context, index) {
              final item = provider.watchlist[index];
              return _WatchlistCard(
                item: item,
                isDark: isDark,
                onRemove: () {
                  provider.toggleWatchlist(item.movieId);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.bookmark,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add movies to your watchlist\nto keep track of what to watch next',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Iconsax.discover),
            label: const Text('Discover Movies'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006BF3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  final bool isDark;

  const _FavoritesTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieContentProvider>(
      builder: (context, provider, child) {
        // For now, favorites and watchlist are the same
        // In a real app, you might separate these
        if (provider.isLoadingWatchlist) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.watchlist.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadWatchlist(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.watchlist.length,
            itemBuilder: (context, index) {
              final item = provider.watchlist[index];
              return _FavoriteCard(
                item: item,
                isDark: isDark,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.heart,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Movies you love will appear here',
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

class _WatchlistCard extends StatelessWidget {
  final WatchlistItem item;
  final bool isDark;
  final VoidCallback onRemove;

  const _WatchlistCard({
    required this.item,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final movie = item.movie;
    if (movie == null) return const SizedBox.shrink();

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onRemove(),
      child: GestureDetector(
        onTap: () => _navigateToDetails(context, movie),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(13)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 100,
                  height: 140,
                  child: movie.posterUrl.isNotEmpty
                      ? Image.network(
                          movie.posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPosterPlaceholder();
                          },
                        )
                      : _buildPosterPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${movie.releaseYear} • ${movie.formattedRuntime}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (movie.genres.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: movie.genres.take(2).map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006BF3).withAlpha(26),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF006BF3),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    onPressed: () => _navigateToDetails(context, movie),
                    icon: Icon(
                      Iconsax.play_circle,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Iconsax.trash,
                      color: Colors.red,
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

  Widget _buildPosterPlaceholder() {
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      child: Icon(
        Iconsax.video,
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
      ),
    );
  }

  void _navigateToDetails(BuildContext context, MovieContent movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsPage(
          movieId: movie.id,
          movie: movie,
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final WatchlistItem item;
  final bool isDark;

  const _FavoriteCard({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final movie = item.movie;
    if (movie == null) return const SizedBox.shrink();

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
                    color: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
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
                // Favorite icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 12,
              ),
              const SizedBox(width: 2),
              Text(
                movie.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
