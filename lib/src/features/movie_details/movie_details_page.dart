import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/models/movie_content.dart';
import '../../core/providers/movie_content_provider.dart';
import 'widgets/cast_list.dart';
import 'widgets/review_section.dart';
import 'widgets/trailer_widget.dart';
import 'video_player_page.dart';

class MovieDetailsPage extends StatefulWidget {
  final String movieId;
  final MovieContent? movie; // Optional: pass movie to avoid refetch

  const MovieDetailsPage({
    super.key,
    required this.movieId,
    this.movie,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieContentProvider>().loadMovieDetails(widget.movieId);
    });
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 200;
    if (showTitle != _showAppBarTitle) {
      setState(() => _showAppBarTitle = showTitle);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Consumer<MovieContentProvider>(
        builder: (context, provider, child) {
          final movie = provider.currentMovie ?? widget.movie;

          if (provider.isLoadingMovie && movie == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (movie == null) {
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
                    'Movie not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(context, movie, isDark),
              SliverToBoxAdapter(
                child: _buildContent(context, movie, isDark, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, MovieContent movie, bool isDark) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(77),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(77),
            shape: BoxShape.circle,
          ),
          child: Consumer<MovieContentProvider>(
            builder: (context, provider, _) {
              final isInWatchlist = provider.isInWatchlist(movie.id);
              return IconButton(
                icon: Icon(
                  isInWatchlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWatchlist ? Colors.red : Colors.white,
                ),
                onPressed: () =>
                    provider.toggleWatchlist(movie.id, movie: movie),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(77),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share functionality
              HapticFeedback.lightImpact();
            },
          ),
        ),
      ],
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          movie.title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop image
            movie.backdropUrl.isNotEmpty
                ? Image.network(
                    movie.backdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                        child: Icon(
                          Iconsax.video,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  )
                : Container(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                    child: Icon(
                      Iconsax.video,
                      size: 64,
                      color: Colors.grey.shade400,
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
                    isDark
                        ? const Color(0xFF121212)
                        : Colors.white,
                  ],
                ),
              ),
            ),
            // Play button
            Center(
              child: GestureDetector(
                onTap: () => _navigateToPlayer(context, movie),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MovieContent movie,
    bool isDark,
    MovieContentProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (movie.tagline != null && movie.tagline!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          movie.tagline!,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _buildRatingBadge(movie.rating, isDark),
            ],
          ),
          const SizedBox(height: 12),

          // Meta info row
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildMetaChip(Icons.calendar_today, movie.releaseYear, isDark),
              _buildMetaChip(Icons.access_time, movie.formattedRuntime, isDark),
              if (movie.contentRating.isNotEmpty)
                _buildMetaChip(Icons.info_outline, movie.contentRating, isDark),
              if (movie.languages.isNotEmpty)
                _buildMetaChip(Icons.language, movie.languages.first, isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Genres
          if (movie.genres.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: movie.genres.map((genre) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(26)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    genre,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToPlayer(context, movie),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006BF3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context,
                Iconsax.document_download,
                'Download',
                isDark,
                onTap: () => _showDownloadOptions(context, movie),
              ),
              const SizedBox(width: 12),
              Consumer<MovieContentProvider>(
                builder: (context, provider, _) {
                  final isInWatchlist = provider.isInWatchlist(movie.id);
                  return _buildActionButton(
                    context,
                    isInWatchlist ? Iconsax.heart5 : Iconsax.heart,
                    'Watchlist',
                    isDark,
                    isActive: isInWatchlist,
                    onTap: () =>
                        provider.toggleWatchlist(movie.id, movie: movie),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(13)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? Colors.white : Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: const Color(0xFF006BF3),
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Trailers'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab content
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(movie, isDark),
                TrailerWidget(movie: movie),
                ReviewSection(movieId: movie.id),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cast
          if (movie.cast.isNotEmpty) ...[
            Text(
              'Cast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            CastList(cast: movie.cast),
          ],
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildAboutTab(MovieContent movie, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Synopsis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.synopsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),

          // Director
          if (movie.director.isNotEmpty) ...[
            _buildInfoRow('Director', movie.director, isDark),
            const SizedBox(height: 12),
          ],

          // Additional info
          if (movie.budget != null && movie.budget! > 0)
            _buildInfoRow(
              'Budget',
              '\$${(movie.budget! / 1000000).toStringAsFixed(0)} million',
              isDark,
            ),
          if (movie.revenue != null && movie.revenue! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildInfoRow(
                'Revenue',
                '\$${(movie.revenue! / 1000000).toStringAsFixed(0)} million',
                isDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBadge(double rating, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getRatingColor(rating).withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRatingColor(rating).withAlpha(77),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: _getRatingColor(rating),
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getRatingColor(rating),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMetaChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF006BF3).withAlpha(26)
                  : (isDark
                      ? Colors.white.withAlpha(26)
                      : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? const Color(0xFF006BF3)
                  : (isDark ? Colors.white70 : Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive
                  ? const Color(0xFF006BF3)
                  : (isDark ? Colors.white70 : Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPlayer(BuildContext context, MovieContent movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(movie: movie),
      ),
    );
  }

  void _showDownloadOptions(BuildContext context, MovieContent movie) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                Text(
                  'Download Quality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ...movie.availableQualities.map((quality) {
                  return ListTile(
                    leading: Icon(
                      Iconsax.video_play,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                    title: Text(
                      quality.label,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      _estimateSize(quality.label, movie.runtime),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context
                          .read<MovieContentProvider>()
                          .startDownload(movie.id, quality.label);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Downloading ${movie.title} in ${quality.label}'),
                          backgroundColor: const Color(0xFF006BF3),
                        ),
                      );
                    },
                  );
                }),
                if (movie.availableQualities.isEmpty) ...[
                  _buildQualityOption(context, '1080p', movie, isDark),
                  _buildQualityOption(context, '720p', movie, isDark),
                  _buildQualityOption(context, '480p', movie, isDark),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQualityOption(
    BuildContext context,
    String quality,
    MovieContent movie,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(
        Iconsax.video_play,
        color: isDark ? Colors.white70 : Colors.grey.shade700,
      ),
      title: Text(
        quality,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        _estimateSize(quality, movie.runtime),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.read<MovieContentProvider>().startDownload(movie.id, quality);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading ${movie.title} in $quality'),
            backgroundColor: const Color(0xFF006BF3),
          ),
        );
      },
    );
  }

  String _estimateSize(String quality, int runtimeMinutes) {
    const sizes = {
      '4K': 4.0,
      '1080p': 2.0,
      '720p': 1.0,
      '480p': 0.5,
    };
    final baseSize = sizes[quality] ?? 1.0;
    final estimatedGB = baseSize * runtimeMinutes / 120;
    if (estimatedGB >= 1) {
      return '~${estimatedGB.toStringAsFixed(1)} GB';
    }
    return '~${(estimatedGB * 1024).toStringAsFixed(0)} MB';
  }
}
