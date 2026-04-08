import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie_content.dart';

/// Service for managing movie content, watchlist, downloads, and recommendations
class MovieContentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton pattern
  static final MovieContentService _instance = MovieContentService._internal();
  factory MovieContentService() => _instance;
  MovieContentService._internal();

  /// Get movie details by ID
  Future<MovieContent?> getMovieDetails(String movieId) async {
    try {
      final response = await _supabase
          .from('movies')
          .select('*, cast(*), crew(*), reviews(*)')
          .eq('id', movieId)
          .single();
      return MovieContent.fromJson(response);
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockMovie(movieId);
    }
  }

  /// Search movies with filters
  Future<List<MovieContent>> searchMovies(SearchFilters filters) async {
    try {
      var query = _supabase.from('movies').select();

      if (filters.query.isNotEmpty) {
        query = query.ilike('title', '%${filters.query}%');
      }

      if (filters.genres.isNotEmpty) {
        query = query.contains('genres', filters.genres);
      }

      if (filters.minRating != null) {
        query = query.gte('rating', filters.minRating!);
      }

      if (filters.yearFrom != null) {
        query = query.gte('release_date', '${filters.yearFrom}-01-01');
      }

      if (filters.yearTo != null) {
        query = query.lte('release_date', '${filters.yearTo}-12-31');
      }

      if (filters.sortBy != null) {
        final response = await query
            .order(filters.sortBy!, ascending: filters.sortAscending)
            .limit(50);
        return (response as List).map((m) => MovieContent.fromJson(m)).toList();
      }

      final response = await query.limit(50);
      return (response as List).map((m) => MovieContent.fromJson(m)).toList();
    } catch (e) {
      // Return mock data for demo
      return _getMockSearchResults(filters.query);
    }
  }

  /// Get movies by genre
  Future<List<MovieContent>> getMoviesByGenre(String genreId) async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .contains('genre_ids', [int.parse(genreId)])
          .order('popularity', ascending: false)
          .limit(20);
      return (response as List).map((m) => MovieContent.fromJson(m)).toList();
    } catch (e) {
      return _getMockMoviesByGenre(genreId);
    }
  }

  /// Get trending movies
  Future<List<MovieContent>> getTrendingMovies() async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .order('popularity', ascending: false)
          .limit(20);
      return (response as List).map((m) => MovieContent.fromJson(m)).toList();
    } catch (e) {
      return _getMockTrendingMovies();
    }
  }

  /// Get all genres
  Future<List<Genre>> getGenres() async {
    try {
      final response = await _supabase.from('genres').select();
      return (response as List).map((g) => Genre.fromJson(g)).toList();
    } catch (e) {
      return Genre.defaultGenres;
    }
  }

  // ==================== WATCHLIST ====================

  /// Add movie to watchlist
  Future<bool> addToWatchlist(String movieId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('watchlist').insert({
        'user_id': userId,
        'movie_id': movieId,
        'added_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove movie from watchlist
  Future<bool> removeFromWatchlist(String movieId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('watchlist')
          .delete()
          .eq('user_id', userId)
          .eq('movie_id', movieId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if movie is in watchlist
  Future<bool> isInWatchlist(String movieId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('watchlist')
          .select('id')
          .eq('user_id', userId)
          .eq('movie_id', movieId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get user's watchlist
  Future<List<WatchlistItem>> getWatchlist() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('watchlist')
          .select('*, movie:movies(*)')
          .eq('user_id', userId)
          .order('added_at', ascending: false);
      return (response as List).map((w) => WatchlistItem.fromJson(w)).toList();
    } catch (e) {
      return _getMockWatchlist();
    }
  }

  // ==================== CONTINUE WATCHING ====================

  /// Update watch progress
  Future<bool> updateWatchProgress(
    String movieId,
    int progress,
    int totalDuration,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('watch_history').upsert({
        'user_id': userId,
        'movie_id': movieId,
        'watch_progress': progress,
        'total_duration': totalDuration,
        'last_watched_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get continue watching list
  Future<List<ContinueWatchingItem>> getContinueWatching() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('watch_history')
          .select('*, movie:movies(*)')
          .eq('user_id', userId)
          .gt('watch_progress', 0)
          .lt('watch_progress', _supabase.rpc('total_duration'))
          .order('last_watched_at', ascending: false)
          .limit(10);
      return (response as List)
          .map((w) => ContinueWatchingItem.fromJson(w))
          .toList();
    } catch (e) {
      return _getMockContinueWatching();
    }
  }

  // ==================== DOWNLOADS ====================

  /// Start download
  Future<DownloadItem?> startDownload(
    String movieId,
    String quality,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final movie = await getMovieDetails(movieId);
      if (movie == null) return null;

      // Calculate file size based on quality
      int fileSize = _estimateFileSize(quality, movie.runtime);

      final downloadItem = DownloadItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        movieId: movieId,
        userId: userId,
        quality: quality,
        fileSize: fileSize,
        status: DownloadStatus.downloading,
        startedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        movie: movie,
      );

      await _supabase.from('downloads').insert(downloadItem.toJson());
      return downloadItem;
    } catch (e) {
      return null;
    }
  }

  /// Get user downloads
  Future<List<DownloadItem>> getDownloads() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('downloads')
          .select('*, movie:movies(*)')
          .eq('user_id', userId)
          .order('started_at', ascending: false);
      return (response as List).map((d) => DownloadItem.fromJson(d)).toList();
    } catch (e) {
      return _getMockDownloads();
    }
  }

  /// Delete download
  Future<bool> deleteDownload(String downloadId) async {
    try {
      await _supabase.from('downloads').delete().eq('id', downloadId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pause download
  Future<bool> pauseDownload(String downloadId) async {
    try {
      await _supabase.from('downloads').update({
        'status': DownloadStatus.paused.name,
      }).eq('id', downloadId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Resume download
  Future<bool> resumeDownload(String downloadId) async {
    try {
      await _supabase.from('downloads').update({
        'status': DownloadStatus.downloading.name,
      }).eq('id', downloadId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== REVIEWS ====================

  /// Submit a review
  Future<bool> submitReview(
    String movieId,
    String content,
    double rating,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('reviews').insert({
        'movie_id': movieId,
        'user_id': user.id,
        'author': user.userMetadata?['display_name'] ?? 'Anonymous',
        'content': content,
        'rating': rating,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get reviews for a movie
  Future<List<Review>> getReviews(String movieId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('movie_id', movieId)
          .order('created_at', ascending: false)
          .limit(50);
      return (response as List).map((r) => Review.fromJson(r)).toList();
    } catch (e) {
      return _getMockReviews();
    }
  }

  // ==================== RECOMMENDATIONS ====================

  /// Get AI-based recommendations
  Future<List<MovieContent>> getRecommendations() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return _getMockRecommendations();

      // Get user's watch history and preferences
      final watchHistory = await _supabase
          .from('watch_history')
          .select('movie:movies(genres)')
          .eq('user_id', userId)
          .order('last_watched_at', ascending: false)
          .limit(20);

      // Extract preferred genres
      final Set<String> preferredGenres = {};
      for (var item in watchHistory) {
        if (item['movie']?['genres'] != null) {
          preferredGenres.addAll(
            (item['movie']['genres'] as List).map((g) => g.toString()),
          );
        }
      }

      if (preferredGenres.isEmpty) {
        return getTrendingMovies();
      }

      // Get movies matching preferred genres
      final response = await _supabase
          .from('movies')
          .select()
          .contains('genres', preferredGenres.take(3).toList())
          .order('popularity', ascending: false)
          .limit(20);

      return (response as List).map((m) => MovieContent.fromJson(m)).toList();
    } catch (e) {
      return _getMockRecommendations();
    }
  }

  /// Get similar movies
  Future<List<MovieContent>> getSimilarMovies(String movieId) async {
    try {
      final movie = await getMovieDetails(movieId);
      if (movie == null) return [];

      final response = await _supabase
          .from('movies')
          .select()
          .neq('id', movieId)
          .contains('genres', movie.genres.take(2).toList())
          .order('popularity', ascending: false)
          .limit(10);

      return (response as List).map((m) => MovieContent.fromJson(m)).toList();
    } catch (e) {
      return _getMockSimilarMovies();
    }
  }

  // ==================== HELPER METHODS ====================

  int _estimateFileSize(String quality, int runtimeMinutes) {
    // Rough estimates in MB
    const qualitySizes = {
      '480p': 400,
      '720p': 800,
      '1080p': 1500,
      '4K': 4000,
    };
    final baseSize = qualitySizes[quality] ?? 800;
    return (baseSize * runtimeMinutes / 120 * 1024 * 1024).round();
  }

  // ==================== MOCK DATA ====================

  MovieContent _getMockMovie(String id) {
    return MovieContent(
      id: id,
      title: 'The Dark Knight',
      originalTitle: 'The Dark Knight',
      posterUrl: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg',
      synopsis: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
      trailerUrl: 'https://www.youtube.com/watch?v=EXeTwQWrcwY',
      streamUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      rating: 9.0,
      voteCount: 30000,
      releaseDate: '2008-07-18',
      runtime: 152,
      genres: ['Action', 'Crime', 'Drama', 'Thriller'],
      cast: [
        const CastMember(
          id: '1',
          name: 'Christian Bale',
          character: 'Bruce Wayne / Batman',
          profileUrl: 'https://image.tmdb.org/t/p/w185/qCpZn2e3dimwbryLnqxZuI88PTi.jpg',
          order: 0,
        ),
        const CastMember(
          id: '2',
          name: 'Heath Ledger',
          character: 'Joker',
          profileUrl: 'https://image.tmdb.org/t/p/w185/5Y9HnYYa9jF4NunY9lSgJGjSe8E.jpg',
          order: 1,
        ),
        const CastMember(
          id: '3',
          name: 'Aaron Eckhart',
          character: 'Harvey Dent',
          profileUrl: 'https://image.tmdb.org/t/p/w185/hDlLJusB5l1pYI0P8K7qM2Ybpiv.jpg',
          order: 2,
        ),
      ],
      director: 'Christopher Nolan',
      contentRating: 'PG-13',
      languages: ['English'],
      availableQualities: const [
        VideoQuality(label: '4K', url: '', bitrate: 15000, width: 3840, height: 2160),
        VideoQuality(label: '1080p', url: '', bitrate: 5000, width: 1920, height: 1080),
        VideoQuality(label: '720p', url: '', bitrate: 2500, width: 1280, height: 720),
        VideoQuality(label: '480p', url: '', bitrate: 1000, width: 854, height: 480),
      ],
      isDownloadable: true,
      downloadSize: 2500,
      totalDuration: 9120,
      tagline: 'Why So Serious?',
      popularity: 100.0,
    );
  }

  List<MovieContent> _getMockSearchResults(String query) {
    return _getMockTrendingMovies()
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<MovieContent> _getMockMoviesByGenre(String genreId) {
    return _getMockTrendingMovies();
  }

  List<MovieContent> _getMockTrendingMovies() {
    return [
      MovieContent(
        id: '1',
        title: 'The Dark Knight',
        posterUrl: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
        backdropUrl: 'https://image.tmdb.org/t/p/original/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg',
        synopsis: 'When the menace known as the Joker wreaks havoc...',
        rating: 9.0,
        releaseDate: '2008-07-18',
        runtime: 152,
        genres: ['Action', 'Crime', 'Drama'],
      ),
      MovieContent(
        id: '2',
        title: 'Inception',
        posterUrl: 'https://image.tmdb.org/t/p/w500/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
        backdropUrl: 'https://image.tmdb.org/t/p/original/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
        synopsis: 'A thief who steals corporate secrets through dream-sharing technology...',
        rating: 8.8,
        releaseDate: '2010-07-16',
        runtime: 148,
        genres: ['Action', 'Science Fiction', 'Adventure'],
      ),
      MovieContent(
        id: '3',
        title: 'Interstellar',
        posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        backdropUrl: 'https://image.tmdb.org/t/p/original/xJHokMbljvjADYdit5fK5VQsXEG.jpg',
        synopsis: 'A team of explorers travel through a wormhole in space...',
        rating: 8.6,
        releaseDate: '2014-11-07',
        runtime: 169,
        genres: ['Adventure', 'Drama', 'Science Fiction'],
      ),
      MovieContent(
        id: '4',
        title: 'The Shawshank Redemption',
        posterUrl: 'https://image.tmdb.org/t/p/w500/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg',
        backdropUrl: 'https://image.tmdb.org/t/p/original/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg',
        synopsis: 'Two imprisoned men bond over a number of years...',
        rating: 9.3,
        releaseDate: '1994-09-23',
        runtime: 142,
        genres: ['Drama', 'Crime'],
      ),
      MovieContent(
        id: '5',
        title: 'Pulp Fiction',
        posterUrl: 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
        backdropUrl: 'https://image.tmdb.org/t/p/original/suaEOtk1N1sgg2MTM7oZd2cfVp3.jpg',
        synopsis: 'The lives of two mob hitmen, a boxer, a gangster and his wife...',
        rating: 8.9,
        releaseDate: '1994-10-14',
        runtime: 154,
        genres: ['Crime', 'Thriller'],
      ),
    ];
  }

  List<WatchlistItem> _getMockWatchlist() {
    final movies = _getMockTrendingMovies();
    return movies.take(3).map((movie) => WatchlistItem(
      id: 'w${movie.id}',
      movieId: movie.id,
      userId: 'user1',
      addedAt: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      movie: movie,
    )).toList();
  }

  List<ContinueWatchingItem> _getMockContinueWatching() {
    final movies = _getMockTrendingMovies();
    return movies.take(2).map((movie) {
      final totalDuration = movie.runtime * 60;
      final progress = (totalDuration * (0.3 + Random().nextDouble() * 0.5)).round();
      return ContinueWatchingItem(
        id: 'cw${movie.id}',
        movieId: movie.id,
        userId: 'user1',
        watchProgress: progress,
        totalDuration: totalDuration,
        lastWatchedAt: DateTime.now().subtract(Duration(hours: Random().nextInt(48))),
        movie: movie,
      );
    }).toList();
  }

  List<DownloadItem> _getMockDownloads() {
    final movies = _getMockTrendingMovies();
    return [
      DownloadItem(
        id: 'd1',
        movieId: movies[0].id,
        userId: 'user1',
        quality: '1080p',
        fileSize: 2500 * 1024 * 1024,
        status: DownloadStatus.completed,
        progress: 1.0,
        startedAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 28)),
        movie: movies[0],
      ),
      DownloadItem(
        id: 'd2',
        movieId: movies[1].id,
        userId: 'user1',
        quality: '720p',
        fileSize: 1200 * 1024 * 1024,
        status: DownloadStatus.downloading,
        progress: 0.65,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        movie: movies[1],
      ),
    ];
  }

  List<Review> _getMockReviews() {
    return [
      Review(
        id: 'r1',
        author: 'MovieFan123',
        authorAvatar: '',
        content: 'Absolutely incredible! Heath Ledger\'s performance as the Joker is legendary. This movie redefined what a superhero film could be.',
        rating: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Review(
        id: 'r2',
        author: 'CinemaLover',
        authorAvatar: '',
        content: 'Dark, intense, and brilliantly directed. Christopher Nolan at his finest. The IMAX sequences are breathtaking.',
        rating: 9,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Review(
        id: 'r3',
        author: 'FilmCritic',
        authorAvatar: '',
        content: 'A masterpiece of modern cinema. The themes of chaos vs order, morality, and sacrifice are explored with unprecedented depth.',
        rating: 9.5,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }

  List<MovieContent> _getMockRecommendations() {
    return _getMockTrendingMovies().reversed.toList();
  }

  List<MovieContent> _getMockSimilarMovies() {
    return _getMockTrendingMovies().skip(2).toList();
  }
}
