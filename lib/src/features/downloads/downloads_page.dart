import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/models/movie_content.dart';
import '../../core/providers/movie_content_provider.dart';
import '../movie_details/movie_details_page.dart';
import '../movie_details/video_player_page.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieContentProvider>().loadDownloads();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Downloads',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<MovieContentProvider>(
            builder: (context, provider, _) {
              if (provider.downloads.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showStorageInfo(context, provider, isDark),
                icon: Icon(
                  Iconsax.chart_2,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MovieContentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDownloads) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.downloads.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return _buildDownloadsList(provider, isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_download,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Downloads Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Download movies and shows to watch\nthem offline without using data',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to discover/browse page
              },
              icon: const Icon(Iconsax.discover),
              label: const Text('Find Something to Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006BF3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadsList(MovieContentProvider provider, bool isDark) {
    // Separate downloading and completed
    final downloading = provider.downloads
        .where((d) =>
            d.status == DownloadStatus.downloading ||
            d.status == DownloadStatus.paused ||
            d.status == DownloadStatus.pending)
        .toList();

    final completed = provider.downloads
        .where((d) => d.status == DownloadStatus.completed)
        .toList();

    return RefreshIndicator(
      onRefresh: () => provider.loadDownloads(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Storage info card
          _buildStorageCard(provider, isDark),
          const SizedBox(height: 20),

          // Downloading section
          if (downloading.isNotEmpty) ...[
            _buildSectionHeader(
              'Downloading',
              '${downloading.length} item${downloading.length > 1 ? 's' : ''}',
              isDark,
            ),
            const SizedBox(height: 12),
            ...downloading.map((item) => _DownloadCard(
                  item: item,
                  isDark: isDark,
                  onPause: () => provider.pauseDownload(item.id),
                  onResume: () => provider.resumeDownload(item.id),
                  onDelete: () => _confirmDelete(context, provider, item),
                )),
            const SizedBox(height: 24),
          ],

          // Completed section
          if (completed.isNotEmpty) ...[
            _buildSectionHeader(
              'Downloaded',
              '${completed.length} item${completed.length > 1 ? 's' : ''}',
              isDark,
            ),
            const SizedBox(height: 12),
            ...completed.map((item) => _DownloadCard(
                  item: item,
                  isDark: isDark,
                  onDelete: () => _confirmDelete(context, provider, item),
                )),
          ],
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildStorageCard(MovieContentProvider provider, bool isDark) {
    final totalSize = provider.downloads
        .where((d) => d.status == DownloadStatus.completed)
        .fold<int>(0, (sum, item) => sum + item.fileSize);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF006BF3).withAlpha(26),
            const Color(0xFF006BF3).withAlpha(51),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF006BF3).withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.folder_open,
              color: Color(0xFF006BF3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage Used',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatFileSize(totalSize),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showStorageInfo(context, provider, isDark),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          count,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  void _showStorageInfo(
    BuildContext context,
    MovieContentProvider provider,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final completed = provider.downloads
            .where((d) => d.status == DownloadStatus.completed)
            .toList();
        final totalSize =
            completed.fold<int>(0, (sum, item) => sum + item.fileSize);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Storage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Storage breakdown
                _buildStorageRow(
                  'Downloads',
                  _formatFileSize(totalSize),
                  const Color(0xFF006BF3),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildStorageRow(
                  'Available',
                  '15.2 GB',
                  Colors.green,
                  isDark,
                ),
                const SizedBox(height: 24),

                // Delete all button
                if (completed.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteAll(context, provider);
                      },
                      icon: const Icon(Iconsax.trash, color: Colors.red),
                      label: const Text('Delete All Downloads'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStorageRow(
      String label, String value, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    MovieContentProvider provider,
    DownloadItem item,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          title: Text(
            'Delete Download?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'This will remove "${item.movie?.title ?? 'this download'}" from your device.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                provider.deleteDownload(item.id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteAll(BuildContext context, MovieContentProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          title: Text(
            'Delete All Downloads?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'This will remove all downloaded movies from your device. This action cannot be undone.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                for (var download in provider.downloads) {
                  provider.deleteDownload(download.id);
                }
              },
              child: const Text(
                'Delete All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _DownloadCard extends StatelessWidget {
  final DownloadItem item;
  final bool isDark;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback onDelete;

  const _DownloadCard({
    required this.item,
    required this.isDark,
    this.onPause,
    this.onResume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final movie = item.movie;
    if (movie == null) return const SizedBox.shrink();

    final isDownloading = item.status == DownloadStatus.downloading;
    final isPaused = item.status == DownloadStatus.paused;
    final isCompleted = item.status == DownloadStatus.completed;

    return GestureDetector(
      onTap: isCompleted ? () => _playOffline(context, movie) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Poster
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 100,
                    child: Stack(
                      children: [
                        movie.posterUrl.isNotEmpty
                            ? Image.network(
                                movie.posterUrl,
                                width: 80,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPosterPlaceholder();
                                },
                              )
                            : _buildPosterPlaceholder(),
                        if (isCompleted)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withAlpha(102),
                              child: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                      ],
                    ),
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusBadge(),
                            const SizedBox(width: 8),
                            Text(
                              '${item.quality} • ${item.fileSizeFormatted}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        if (item.expiresAt != null && isCompleted) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Expires in ${_getExpiryText(item.expiresAt!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: item.isExpired
                                  ? Colors.red
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Actions
                _buildActionButton(context),
              ],
            ),

            // Progress bar (for downloading)
            if (!isCompleted)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        backgroundColor: isDark
                            ? Colors.white.withAlpha(26)
                            : Colors.grey.shade200,
                        color: isPaused ? Colors.grey : const Color(0xFF006BF3),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(item.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (isDownloading)
                          Text(
                            'Downloading...',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        if (isPaused)
                          const Text(
                            'Paused',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
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

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;

    switch (item.status) {
      case DownloadStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DownloadStatus.downloading:
        color = const Color(0xFF006BF3);
        icon = Iconsax.arrow_down_2;
        break;
      case DownloadStatus.paused:
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case DownloadStatus.failed:
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.pending;
    }

    return Icon(icon, color: color, size: 16);
  }

  Widget _buildActionButton(BuildContext context) {
    if (item.status == DownloadStatus.downloading) {
      return IconButton(
        onPressed: onPause,
        icon: const Icon(
          Icons.pause_circle_outline,
          color: Color(0xFF006BF3),
        ),
      );
    }

    if (item.status == DownloadStatus.paused) {
      return IconButton(
        onPressed: onResume,
        icon: const Icon(
          Icons.play_circle_outline,
          color: Color(0xFF006BF3),
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: isDark ? Colors.white70 : Colors.grey.shade700,
      ),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      itemBuilder: (context) => [
        if (item.status == DownloadStatus.completed) ...[
          PopupMenuItem(
            value: 'play',
            child: Row(
              children: [
                const Icon(Iconsax.play, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Play',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'info',
            child: Row(
              children: [
                const Icon(Iconsax.info_circle, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Info',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Iconsax.trash, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'play') {
          _playOffline(context, item.movie!);
        } else if (value == 'info') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsPage(
                movieId: item.movieId,
                movie: item.movie,
              ),
            ),
          );
        } else if (value == 'delete') {
          onDelete();
        }
      },
    );
  }

  void _playOffline(BuildContext context, MovieContent movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(movie: movie),
      ),
    );
  }

  String _getExpiryText(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) return 'Expired';
    if (difference.inDays > 0) return '${difference.inDays} days';
    if (difference.inHours > 0) return '${difference.inHours} hours';
    return '${difference.inMinutes} minutes';
  }
}
