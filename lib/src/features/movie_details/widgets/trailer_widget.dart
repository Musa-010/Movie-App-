import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/movie_content.dart';

class TrailerWidget extends StatefulWidget {
  final MovieContent movie;

  const TrailerWidget({
    super.key,
    required this.movie,
  });

  @override
  State<TrailerWidget> createState() => _TrailerWidgetState();
}

class _TrailerWidgetState extends State<TrailerWidget> {
  int _selectedTrailerIndex = 0;

  // Mock trailer data
  final List<_TrailerInfo> _trailers = [
    _TrailerInfo(
      title: 'Official Trailer',
      duration: '2:31',
      thumbnailUrl: '',
      videoUrl: '',
    ),
    _TrailerInfo(
      title: 'Teaser Trailer',
      duration: '1:45',
      thumbnailUrl: '',
      videoUrl: '',
    ),
    _TrailerInfo(
      title: 'Behind The Scenes',
      duration: '5:12',
      thumbnailUrl: '',
      videoUrl: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main trailer player
          _buildMainPlayer(isDark),
          const SizedBox(height: 16),

          // Trailer list
          Text(
            'Videos & Trailers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_trailers.length, (index) {
            return _buildTrailerItem(index, isDark);
          }),
        ],
      ),
    );
  }

  Widget _buildMainPlayer(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: widget.movie.backdropUrl.isNotEmpty
                ? Image.network(
                    widget.movie.backdropUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(isDark);
                    },
                  )
                : _buildPlaceholder(isDark),
          ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(153),
                ],
              ),
            ),
          ),

          // Play button
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 36,
                color: Colors.black,
              ),
            ),
          ),

          // Duration badge
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _trailers[_selectedTrailerIndex].duration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Title
          Positioned(
            bottom: 12,
            left: 12,
            child: Text(
              _trailers[_selectedTrailerIndex].title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      child: Center(
        child: Icon(
          Iconsax.video_play,
          size: 48,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildTrailerItem(int index, bool isDark) {
    final trailer = _trailers[index];
    final isSelected = index == _selectedTrailerIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedTrailerIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF006BF3).withAlpha(26)
              : (isDark
                  ? Colors.white.withAlpha(13)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF006BF3).withAlpha(77))
              : null,
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.movie.backdropUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.movie.backdropUrl,
                        width: 80,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Iconsax.video_play,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade500,
                          );
                        },
                      ),
                    ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(204),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trailer.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trailer.duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF006BF3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _TrailerInfo {
  final String title;
  final String duration;
  final String thumbnailUrl;
  final String videoUrl;

  _TrailerInfo({
    required this.title,
    required this.duration,
    required this.thumbnailUrl,
    required this.videoUrl,
  });
}
