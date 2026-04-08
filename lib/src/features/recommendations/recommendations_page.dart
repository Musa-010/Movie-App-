import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/models/movie_content.dart';
import '../../core/providers/movie_content_provider.dart';
import '../movie_details/movie_details_page.dart';
import '../movie_details/video_player_page.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieContentProvider>().loadRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF006BF3),
                    const Color(0xFF006BF3).withAlpha(179),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.magic_star,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'For You',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showRecommendationInfo(context, isDark),
            icon: Icon(
              Iconsax.info_circle,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
      body: Consumer<MovieContentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingRecommendations && provider.recommendations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.recommendations.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadRecommendations(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI recommendation banner
                  _buildAIBanner(isDark),
                  const SizedBox(height: 24),

                  // Continue watching section
                  if (provider.continueWatching.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Continue Watching',
                      Iconsax.clock,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _ContinueWatchingSection(
                      items: provider.continueWatching,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Personalized recommendations
                  _buildSectionHeader(
                    'Recommended for You',
                    Iconsax.magic_star,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _RecommendationGrid(
                    movies: provider.recommendations,
                    isDark: isDark,
                  ),

                  // Trending section
                  if (provider.trendingMovies.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Trending Now',
                      Iconsax.chart,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _TrendingSection(
                      movies: provider.trendingMovies,
                      isDark: isDark,
                    ),
                  ],

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAIBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.cpu,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI-Powered Picks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your watch history and preferences',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF006BF3),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.magic_star,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No recommendations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Watch some movies to get\npersonalized recommendations',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRecommendationInfo(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006BF3).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Iconsax.cpu,
                        color: Color(0xFF006BF3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'How Recommendations Work',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoItem(
                  Iconsax.clock,
                  'Watch History',
                  'We analyze the movies you\'ve watched to understand your taste',
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Iconsax.category,
                  'Genre Preferences',
                  'Your favorite genres help us find similar content',
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Iconsax.star,
                  'Ratings & Reviews',
                  'Movies you\'ve rated highly influence your recommendations',
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Iconsax.people,
                  'Similar Users',
                  'We find users with similar tastes and suggest their favorites',
                  isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String title,
    String description,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey.shade500,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContinueWatchingSection extends StatelessWidget {
  final List<ContinueWatchingItem> items;
  final bool isDark;

  const _ContinueWatchingSection({
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _ContinueWatchingCard(
            item: item,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  final ContinueWatchingItem item;
  final bool isDark;

  const _ContinueWatchingCard({
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
            builder: (context) => VideoPlayerPage(
              movie: movie,
              startPosition: item.watchProgress,
            ),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: movie.backdropUrl.isNotEmpty
                        ? Image.network(
                            movie.backdropUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                              );
                            },
                          )
                        : Container(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                          ),
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(153),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(230),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Remaining time badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(179),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.remainingTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            LinearProgressIndicator(
              value: item.progressPercent / 100,
              backgroundColor: isDark
                  ? Colors.white.withAlpha(26)
                  : Colors.grey.shade300,
              color: const Color(0xFF006BF3),
              minHeight: 3,
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.progressPercent.toStringAsFixed(0)}% watched',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
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
}

class _RecommendationGrid extends StatelessWidget {
  final List<MovieContent> movies;
  final bool isDark;

  const _RecommendationGrid({
    required this.movies,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return _RecommendationCard(
          movie: movies[index],
          matchScore: 85 + (index % 15), // Mock match score
          isDark: isDark,
        );
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final MovieContent movie;
  final int matchScore;
  final bool isDark;

  const _RecommendationCard({
    required this.movie,
    required this.matchScore,
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
                // Match score badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.magic_star,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$matchScore%',
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
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                movie.releaseYear,
                style: TextStyle(
                  fontSize: 11,
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

class _TrendingSection extends StatelessWidget {
  final List<MovieContent> movies;
  final bool isDark;

  const _TrendingSection({
    required this.movies,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return _TrendingCard(
            movie: movies[index],
            rank: index + 1,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final MovieContent movie;
  final int rank;
  final bool isDark;

  const _TrendingCard({
    required this.movie,
    required this.rank,
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
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Poster
            Positioned(
              left: 20,
              top: 0,
              right: 0,
              bottom: 30,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: movie.posterUrl.isNotEmpty
                      ? Image.network(
                          movie.posterUrl,
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
            ),
            // Rank number
            Positioned(
              left: 0,
              bottom: 0,
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: isDark
                          ? Colors.black.withAlpha(128)
                          : Colors.white.withAlpha(128),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
