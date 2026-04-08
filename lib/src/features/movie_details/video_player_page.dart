import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/models/movie_content.dart';
import '../../core/providers/movie_content_provider.dart';

class VideoPlayerPage extends StatefulWidget {
  final MovieContent movie;
  final int? startPosition; // in seconds

  const VideoPlayerPage({
    super.key,
    required this.movie,
    this.startPosition,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _selectedQuality = '720p';

  // Sample video URLs for testing (reliable test streams)
  final Map<String, String> _sampleVideos = {
    '1080p': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    '720p': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    '480p': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    '360p': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  };

  @override
  void initState() {
    super.initState();
    _enterFullScreen();
    _initializePlayer();
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initializePlayer() async {
    try {
      // Use movie's stream URL if available, otherwise use sample video
      String videoUrl = widget.movie.streamUrl.isNotEmpty 
          ? widget.movie.streamUrl 
          : _sampleVideos[_selectedQuality]!;

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoPlayerController!.initialize();

      // Seek to start position if provided
      if (widget.startPosition != null && widget.startPosition! > 0) {
        await _videoPlayerController!.seekTo(
          Duration(seconds: widget.startPosition!),
        );
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showControlsOnInitialize: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retryInitialization,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF006BF3),
          handleColor: const Color(0xFF006BF3),
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.grey.shade600,
        ),
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
              onTap: (context) => _showQualitySelector(context),
              iconData: Icons.high_quality,
              title: 'Quality: $_selectedQuality',
            ),
          ];
        },
      );

      // Listen for position updates to save progress
      _videoPlayerController!.addListener(_onVideoProgress);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onVideoProgress() {
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      final position = _videoPlayerController!.value.position.inSeconds;
      final duration = _videoPlayerController!.value.duration.inSeconds;
      
      // Update watch progress every 10 seconds
      if (position % 10 == 0 && position > 0) {
        context.read<MovieContentProvider>().updateWatchProgress(
          widget.movie.id,
          position,
          duration,
        );
      }
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    await _disposeControllers();
    await _initializePlayer();
  }

  Future<void> _changeQuality(String quality) async {
    if (quality == _selectedQuality) return;

    final currentPosition = _videoPlayerController?.value.position;
    
    setState(() {
      _selectedQuality = quality;
      _isInitialized = false;
    });

    await _disposeControllers();

    // Re-initialize with new quality
    try {
      String videoUrl = _sampleVideos[quality] ?? _sampleVideos['720p']!;

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoPlayerController!.initialize();

      // Seek to previous position
      if (currentPosition != null) {
        await _videoPlayerController!.seekTo(currentPosition);
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF006BF3),
          handleColor: const Color(0xFF006BF3),
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.grey.shade600,
        ),
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
              onTap: (context) => _showQualitySelector(context),
              iconData: Icons.high_quality,
              title: 'Quality: $_selectedQuality',
            ),
          ];
        },
      );

      _videoPlayerController!.addListener(_onVideoProgress);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showQualitySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Video Quality',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...['1080p', '720p', '480p', '360p'].map((quality) {
                final isSelected = quality == _selectedQuality;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? const Color(0xFF006BF3) : Colors.grey,
                  ),
                  title: Text(
                    quality,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF006BF3) : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    _getQualityDescription(quality),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _changeQuality(quality);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _getQualityDescription(String quality) {
    switch (quality) {
      case '1080p':
        return 'Full HD • Best quality';
      case '720p':
        return 'HD • Recommended';
      case '480p':
        return 'SD • Saves data';
      case '360p':
        return 'Low • Minimal data';
      default:
        return '';
    }
  }

  Future<void> _disposeControllers() async {
    _videoPlayerController?.removeListener(_onVideoProgress);
    _chewieController?.dispose();
    _chewieController = null;
    await _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    _exitFullScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player
          if (_isInitialized && _chewieController != null)
            Center(
              child: Chewie(controller: _chewieController!),
            )
          else if (_hasError)
            _buildErrorWidget()
          else
            _buildLoadingWidget(),

          // Back button (always visible at top left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Movie title (top center when loading)
          if (!_isInitialized && !_hasError)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 60,
              right: 60,
              child: Text(
                widget.movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Movie poster/backdrop
          if (widget.movie.backdropUrl.isNotEmpty)
            Opacity(
              opacity: 0.3,
              child: Image.network(
                widget.movie.backdropUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox();
                },
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF006BF3),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Loading video...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quality: $_selectedQuality',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.video_slash,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to load video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _retryInitialization,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006BF3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
