import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/movie_content.dart';
import '../services/movie_content_service.dart';

/// Provider for managing movie content state
class MovieContentProvider with ChangeNotifier {
  final MovieContentService _service = MovieContentService();

  // Current movie details
  MovieContent? _currentMovie;
  bool _isLoadingMovie = false;
  String? _movieError;

  // Search
  List<MovieContent> _searchResults = [];
  bool _isSearching = false;
  SearchFilters _searchFilters = const SearchFilters();
  String? _searchError;
  List<String> _recentSearches = [];

  // Genres
  List<Genre> _genres = [];
  bool _isLoadingGenres = false;

  // Trending
  List<MovieContent> _trendingMovies = [];
  bool _isLoadingTrending = false;

  // Watchlist
  List<WatchlistItem> _watchlist = [];
  bool _isLoadingWatchlist = false;
  final Set<String> _watchlistIds = {};

  // Continue watching
  List<ContinueWatchingItem> _continueWatching = [];
  bool _isLoadingContinueWatching = false;

  // Downloads
  List<DownloadItem> _downloads = [];
  bool _isLoadingDownloads = false;
  final Map<String, StreamController<DownloadItem>> _downloadStreams = {};

  // Recommendations
  List<MovieContent> _recommendations = [];
  bool _isLoadingRecommendations = false;

  // Reviews
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;

  // Getters
  MovieContent? get currentMovie => _currentMovie;
  bool get isLoadingMovie => _isLoadingMovie;
  String? get movieError => _movieError;

  List<MovieContent> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  SearchFilters get searchFilters => _searchFilters;
  String? get searchError => _searchError;
  List<String> get recentSearches => _recentSearches;

  List<Genre> get genres => _genres;
  bool get isLoadingGenres => _isLoadingGenres;

  List<MovieContent> get trendingMovies => _trendingMovies;
  bool get isLoadingTrending => _isLoadingTrending;

  List<WatchlistItem> get watchlist => _watchlist;
  bool get isLoadingWatchlist => _isLoadingWatchlist;

  List<ContinueWatchingItem> get continueWatching => _continueWatching;
  bool get isLoadingContinueWatching => _isLoadingContinueWatching;

  List<DownloadItem> get downloads => _downloads;
  bool get isLoadingDownloads => _isLoadingDownloads;
  int get completedDownloadsCount =>
      _downloads.where((d) => d.status == DownloadStatus.completed).length;
  int get activeDownloadsCount =>
      _downloads.where((d) => d.status == DownloadStatus.downloading).length;

  List<MovieContent> get recommendations => _recommendations;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  List<Review> get reviews => _reviews;
  bool get isLoadingReviews => _isLoadingReviews;

  /// Initialize provider
  Future<void> initialize() async {
    await Future.wait([
      loadGenres(),
      loadTrendingMovies(),
      loadWatchlist(),
      loadContinueWatching(),
      loadDownloads(),
      loadRecommendations(),
    ]);
  }

  // ==================== MOVIE DETAILS ====================

  /// Load movie details
  Future<void> loadMovieDetails(String movieId) async {
    _isLoadingMovie = true;
    _movieError = null;
    notifyListeners();

    try {
      _currentMovie = await _service.getMovieDetails(movieId);
      if (_currentMovie != null) {
        await loadReviews(movieId);
      }
    } catch (e) {
      _movieError = e.toString();
    }

    _isLoadingMovie = false;
    notifyListeners();
  }

  /// Clear current movie
  void clearCurrentMovie() {
    _currentMovie = null;
    _reviews = [];
    notifyListeners();
  }

  // ==================== SEARCH ====================

  /// Search movies
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      final filters = _searchFilters.copyWith(query: query);
      _searchResults = await _service.searchMovies(filters);
      _addToRecentSearches(query);
    } catch (e) {
      _searchError = e.toString();
    }

    _isSearching = false;
    notifyListeners();
  }

  /// Update search filters
  void updateSearchFilters(SearchFilters filters) {
    _searchFilters = filters;
    notifyListeners();
  }

  /// Clear search filters
  void clearSearchFilters() {
    _searchFilters = const SearchFilters();
    notifyListeners();
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    _searchFilters = const SearchFilters();
    _searchError = null;
    notifyListeners();
  }

  void _addToRecentSearches(String query) {
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }
  }

  void clearRecentSearches() {
    _recentSearches = [];
    notifyListeners();
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }

  // ==================== GENRES ====================

  /// Load genres
  Future<void> loadGenres() async {
    _isLoadingGenres = true;
    notifyListeners();

    try {
      _genres = await _service.getGenres();
    } catch (e) {
      _genres = Genre.defaultGenres;
    }

    _isLoadingGenres = false;
    notifyListeners();
  }

  /// Get movies by genre
  Future<List<MovieContent>> getMoviesByGenre(String genreId) async {
    return _service.getMoviesByGenre(genreId);
  }

  // ==================== TRENDING ====================

  /// Load trending movies
  Future<void> loadTrendingMovies() async {
    _isLoadingTrending = true;
    notifyListeners();

    try {
      _trendingMovies = await _service.getTrendingMovies();
    } catch (e) {
      // Handle error silently
    }

    _isLoadingTrending = false;
    notifyListeners();
  }

  // ==================== WATCHLIST ====================

  /// Load watchlist
  Future<void> loadWatchlist() async {
    _isLoadingWatchlist = true;
    notifyListeners();

    try {
      _watchlist = await _service.getWatchlist();
      _watchlistIds.clear();
      for (var item in _watchlist) {
        _watchlistIds.add(item.movieId);
      }
    } catch (e) {
      // Handle error silently
    }

    _isLoadingWatchlist = false;
    notifyListeners();
  }

  /// Check if movie is in watchlist
  bool isInWatchlist(String movieId) {
    return _watchlistIds.contains(movieId);
  }

  /// Toggle watchlist
  Future<bool> toggleWatchlist(String movieId, {MovieContent? movie}) async {
    final isCurrentlyInWatchlist = isInWatchlist(movieId);

    // Optimistic update
    if (isCurrentlyInWatchlist) {
      _watchlistIds.remove(movieId);
      _watchlist.removeWhere((item) => item.movieId == movieId);
    } else {
      _watchlistIds.add(movieId);
      if (movie != null) {
        _watchlist.insert(
          0,
          WatchlistItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            movieId: movieId,
            userId: '',
            addedAt: DateTime.now(),
            movie: movie,
          ),
        );
      }
    }
    notifyListeners();

    // Make API call
    bool success;
    if (isCurrentlyInWatchlist) {
      success = await _service.removeFromWatchlist(movieId);
    } else {
      success = await _service.addToWatchlist(movieId);
    }

    // Revert if failed
    if (!success) {
      if (isCurrentlyInWatchlist) {
        _watchlistIds.add(movieId);
        await loadWatchlist(); // Reload to get correct state
      } else {
        _watchlistIds.remove(movieId);
        _watchlist.removeWhere((item) => item.movieId == movieId);
      }
      notifyListeners();
    }

    return success;
  }

  // ==================== CONTINUE WATCHING ====================

  /// Load continue watching
  Future<void> loadContinueWatching() async {
    _isLoadingContinueWatching = true;
    notifyListeners();

    try {
      _continueWatching = await _service.getContinueWatching();
    } catch (e) {
      // Handle error silently
    }

    _isLoadingContinueWatching = false;
    notifyListeners();
  }

  /// Update watch progress
  Future<void> updateWatchProgress(
    String movieId,
    int progress,
    int totalDuration,
  ) async {
    await _service.updateWatchProgress(movieId, progress, totalDuration);

    // Update local state
    final index = _continueWatching.indexWhere((c) => c.movieId == movieId);
    if (index >= 0) {
      final item = _continueWatching[index];
      _continueWatching[index] = ContinueWatchingItem(
        id: item.id,
        movieId: item.movieId,
        userId: item.userId,
        watchProgress: progress,
        totalDuration: totalDuration,
        lastWatchedAt: DateTime.now(),
        movie: item.movie,
      );
      notifyListeners();
    }
  }

  // ==================== DOWNLOADS ====================

  /// Load downloads
  Future<void> loadDownloads() async {
    _isLoadingDownloads = true;
    notifyListeners();

    try {
      _downloads = await _service.getDownloads();
    } catch (e) {
      // Handle error silently
    }

    _isLoadingDownloads = false;
    notifyListeners();
  }

  /// Start download
  Future<DownloadItem?> startDownload(String movieId, String quality) async {
    final downloadItem = await _service.startDownload(movieId, quality);
    if (downloadItem != null) {
      _downloads.insert(0, downloadItem);
      notifyListeners();
      _simulateDownload(downloadItem);
    }
    return downloadItem;
  }

  /// Simulate download progress (for demo)
  void _simulateDownload(DownloadItem item) {
    final controller = StreamController<DownloadItem>();
    _downloadStreams[item.id] = controller;

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final index = _downloads.indexWhere((d) => d.id == item.id);
      if (index < 0) {
        timer.cancel();
        controller.close();
        return;
      }

      final current = _downloads[index];
      if (current.status == DownloadStatus.paused) {
        return; // Skip if paused
      }

      if (current.progress >= 1.0) {
        _downloads[index] = current.copyWith(
          status: DownloadStatus.completed,
          completedAt: DateTime.now(),
        );
        notifyListeners();
        timer.cancel();
        controller.close();
        return;
      }

      _downloads[index] = current.copyWith(
        progress: (current.progress + 0.05).clamp(0.0, 1.0),
      );
      notifyListeners();
    });
  }

  /// Pause download
  Future<void> pauseDownload(String downloadId) async {
    final index = _downloads.indexWhere((d) => d.id == downloadId);
    if (index >= 0) {
      _downloads[index] = _downloads[index].copyWith(
        status: DownloadStatus.paused,
      );
      notifyListeners();
      await _service.pauseDownload(downloadId);
    }
  }

  /// Resume download
  Future<void> resumeDownload(String downloadId) async {
    final index = _downloads.indexWhere((d) => d.id == downloadId);
    if (index >= 0) {
      _downloads[index] = _downloads[index].copyWith(
        status: DownloadStatus.downloading,
      );
      notifyListeners();
      await _service.resumeDownload(downloadId);
    }
  }

  /// Delete download
  Future<void> deleteDownload(String downloadId) async {
    _downloads.removeWhere((d) => d.id == downloadId);
    notifyListeners();
    await _service.deleteDownload(downloadId);
    _downloadStreams[downloadId]?.close();
    _downloadStreams.remove(downloadId);
  }

  /// Check if movie is downloaded
  bool isDownloaded(String movieId) {
    return _downloads.any(
      (d) => d.movieId == movieId && d.status == DownloadStatus.completed,
    );
  }

  /// Check if movie is downloading
  bool isDownloading(String movieId) {
    return _downloads.any(
      (d) =>
          d.movieId == movieId &&
          (d.status == DownloadStatus.downloading ||
              d.status == DownloadStatus.pending),
    );
  }

  // ==================== REVIEWS ====================

  /// Load reviews for a movie
  Future<void> loadReviews(String movieId) async {
    _isLoadingReviews = true;
    notifyListeners();

    try {
      _reviews = await _service.getReviews(movieId);
    } catch (e) {
      // Handle error silently
    }

    _isLoadingReviews = false;
    notifyListeners();
  }

  /// Submit review
  Future<bool> submitReview(
    String movieId,
    String content,
    double rating,
  ) async {
    final success = await _service.submitReview(movieId, content, rating);
    if (success) {
      await loadReviews(movieId);
    }
    return success;
  }

  // ==================== RECOMMENDATIONS ====================

  /// Load recommendations
  Future<void> loadRecommendations() async {
    _isLoadingRecommendations = true;
    notifyListeners();

    try {
      _recommendations = await _service.getRecommendations();
    } catch (e) {
      // Handle error silently
    }

    _isLoadingRecommendations = false;
    notifyListeners();
  }

  /// Get similar movies
  Future<List<MovieContent>> getSimilarMovies(String movieId) async {
    return _service.getSimilarMovies(movieId);
  }

  @override
  void dispose() {
    for (var controller in _downloadStreams.values) {
      controller.close();
    }
    super.dispose();
  }
}
