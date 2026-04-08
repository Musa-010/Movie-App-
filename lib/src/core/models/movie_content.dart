/// Enhanced movie content model for streaming features
class MovieContent {
  final String id;
  final String title;
  final String originalTitle;
  final String posterUrl;
  final String backdropUrl;
  final String synopsis;
  final String trailerUrl;
  final String streamUrl;
  final double rating;
  final int voteCount;
  final String releaseDate;
  final int runtime; // in minutes
  final List<String> genres;
  final List<CastMember> cast;
  final List<CrewMember> crew;
  final String director;
  final String contentRating; // PG, PG-13, R, etc.
  final List<String> languages;
  final List<VideoQuality> availableQualities;
  final bool isDownloadable;
  final int downloadSize; // in MB
  final DateTime? lastWatchedAt;
  final int watchProgress; // in seconds
  final int totalDuration; // in seconds
  final String? ageRating;
  final List<String> keywords;
  final double popularity;
  final String status; // released, upcoming, etc.
  final int? budget;
  final int? revenue;
  final String? tagline;
  final List<ProductionCompany> productionCompanies;
  final List<Review> reviews;
  final List<MovieContent> similarMovies;
  final List<MovieContent> recommendations;

  const MovieContent({
    required this.id,
    required this.title,
    this.originalTitle = '',
    required this.posterUrl,
    required this.backdropUrl,
    required this.synopsis,
    this.trailerUrl = '',
    this.streamUrl = '',
    this.rating = 0.0,
    this.voteCount = 0,
    required this.releaseDate,
    this.runtime = 0,
    this.genres = const [],
    this.cast = const [],
    this.crew = const [],
    this.director = '',
    this.contentRating = '',
    this.languages = const [],
    this.availableQualities = const [],
    this.isDownloadable = false,
    this.downloadSize = 0,
    this.lastWatchedAt,
    this.watchProgress = 0,
    this.totalDuration = 0,
    this.ageRating,
    this.keywords = const [],
    this.popularity = 0.0,
    this.status = 'released',
    this.budget,
    this.revenue,
    this.tagline,
    this.productionCompanies = const [],
    this.reviews = const [],
    this.similarMovies = const [],
    this.recommendations = const [],
  });

  /// Calculate watch progress percentage
  double get watchProgressPercent {
    if (totalDuration == 0) return 0;
    return (watchProgress / totalDuration) * 100;
  }

  /// Format runtime as "Xh Ym"
  String get formattedRuntime {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Get year from release date
  String get releaseYear {
    if (releaseDate.isEmpty) return '';
    return releaseDate.split('-').first;
  }

  MovieContent copyWith({
    String? id,
    String? title,
    String? originalTitle,
    String? posterUrl,
    String? backdropUrl,
    String? synopsis,
    String? trailerUrl,
    String? streamUrl,
    double? rating,
    int? voteCount,
    String? releaseDate,
    int? runtime,
    List<String>? genres,
    List<CastMember>? cast,
    List<CrewMember>? crew,
    String? director,
    String? contentRating,
    List<String>? languages,
    List<VideoQuality>? availableQualities,
    bool? isDownloadable,
    int? downloadSize,
    DateTime? lastWatchedAt,
    int? watchProgress,
    int? totalDuration,
    String? ageRating,
    List<String>? keywords,
    double? popularity,
    String? status,
    int? budget,
    int? revenue,
    String? tagline,
    List<ProductionCompany>? productionCompanies,
    List<Review>? reviews,
    List<MovieContent>? similarMovies,
    List<MovieContent>? recommendations,
  }) {
    return MovieContent(
      id: id ?? this.id,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      synopsis: synopsis ?? this.synopsis,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      rating: rating ?? this.rating,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      cast: cast ?? this.cast,
      crew: crew ?? this.crew,
      director: director ?? this.director,
      contentRating: contentRating ?? this.contentRating,
      languages: languages ?? this.languages,
      availableQualities: availableQualities ?? this.availableQualities,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      downloadSize: downloadSize ?? this.downloadSize,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      watchProgress: watchProgress ?? this.watchProgress,
      totalDuration: totalDuration ?? this.totalDuration,
      ageRating: ageRating ?? this.ageRating,
      keywords: keywords ?? this.keywords,
      popularity: popularity ?? this.popularity,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      revenue: revenue ?? this.revenue,
      tagline: tagline ?? this.tagline,
      productionCompanies: productionCompanies ?? this.productionCompanies,
      reviews: reviews ?? this.reviews,
      similarMovies: similarMovies ?? this.similarMovies,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'synopsis': synopsis,
      'trailer_url': trailerUrl,
      'stream_url': streamUrl,
      'rating': rating,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'runtime': runtime,
      'genres': genres,
      'cast': cast.map((c) => c.toJson()).toList(),
      'crew': crew.map((c) => c.toJson()).toList(),
      'director': director,
      'content_rating': contentRating,
      'languages': languages,
      'available_qualities': availableQualities.map((q) => q.toJson()).toList(),
      'is_downloadable': isDownloadable,
      'download_size': downloadSize,
      'last_watched_at': lastWatchedAt?.toIso8601String(),
      'watch_progress': watchProgress,
      'total_duration': totalDuration,
      'age_rating': ageRating,
      'keywords': keywords,
      'popularity': popularity,
      'status': status,
      'budget': budget,
      'revenue': revenue,
      'tagline': tagline,
      'production_companies': productionCompanies.map((p) => p.toJson()).toList(),
    };
  }

  factory MovieContent.fromJson(Map<String, dynamic> json) {
    return MovieContent(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      originalTitle: json['original_title'] ?? '',
      posterUrl: json['poster_url'] ?? json['poster_path'] ?? '',
      backdropUrl: json['backdrop_url'] ?? json['backdrop_path'] ?? '',
      synopsis: json['synopsis'] ?? json['overview'] ?? '',
      trailerUrl: json['trailer_url'] ?? '',
      streamUrl: json['stream_url'] ?? '',
      rating: (json['rating'] ?? json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: json['release_date'] ?? '',
      runtime: json['runtime'] ?? 0,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => g is String ? g : (g['name'] ?? '').toString())
              .toList() ??
          [],
      cast: (json['cast'] as List<dynamic>?)
              ?.map((c) => CastMember.fromJson(c))
              .toList() ??
          [],
      crew: (json['crew'] as List<dynamic>?)
              ?.map((c) => CrewMember.fromJson(c))
              .toList() ??
          [],
      director: json['director'] ?? '',
      contentRating: json['content_rating'] ?? '',
      languages: (json['languages'] as List<dynamic>?)
              ?.map((l) => l.toString())
              .toList() ??
          [],
      availableQualities: (json['available_qualities'] as List<dynamic>?)
              ?.map((q) => VideoQuality.fromJson(q))
              .toList() ??
          [],
      isDownloadable: json['is_downloadable'] ?? false,
      downloadSize: json['download_size'] ?? 0,
      lastWatchedAt: json['last_watched_at'] != null
          ? DateTime.parse(json['last_watched_at'])
          : null,
      watchProgress: json['watch_progress'] ?? 0,
      totalDuration: json['total_duration'] ?? 0,
      ageRating: json['age_rating'],
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((k) => k.toString())
              .toList() ??
          [],
      popularity: (json['popularity'] ?? 0).toDouble(),
      status: json['status'] ?? 'released',
      budget: json['budget'],
      revenue: json['revenue'],
      tagline: json['tagline'],
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map((p) => ProductionCompany.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class CastMember {
  final String id;
  final String name;
  final String character;
  final String profileUrl;
  final int order;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profileUrl = '',
    this.order = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profile_url': profileUrl,
      'order': order,
    };
  }

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profileUrl: json['profile_url'] ?? json['profile_path'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}

class CrewMember {
  final String id;
  final String name;
  final String job;
  final String department;
  final String profileUrl;

  const CrewMember({
    required this.id,
    required this.name,
    required this.job,
    this.department = '',
    this.profileUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'job': job,
      'department': department,
      'profile_url': profileUrl,
    };
  }

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      job: json['job'] ?? '',
      department: json['department'] ?? '',
      profileUrl: json['profile_url'] ?? json['profile_path'] ?? '',
    );
  }
}

class VideoQuality {
  final String label; // e.g., "1080p", "720p", "480p"
  final String url;
  final int bitrate; // in kbps
  final int width;
  final int height;

  const VideoQuality({
    required this.label,
    required this.url,
    this.bitrate = 0,
    this.width = 0,
    this.height = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'url': url,
      'bitrate': bitrate,
      'width': width,
      'height': height,
    };
  }

  factory VideoQuality.fromJson(Map<String, dynamic> json) {
    return VideoQuality(
      label: json['label'] ?? '',
      url: json['url'] ?? '',
      bitrate: json['bitrate'] ?? 0,
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }
}

class ProductionCompany {
  final String id;
  final String name;
  final String logoUrl;
  final String country;

  const ProductionCompany({
    required this.id,
    required this.name,
    this.logoUrl = '',
    this.country = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'country': country,
    };
  }

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logo_url'] ?? json['logo_path'] ?? '',
      country: json['origin_country'] ?? '',
    );
  }
}

class Review {
  final String id;
  final String author;
  final String authorAvatar;
  final String content;
  final double rating;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.author,
    this.authorAvatar = '',
    required this.content,
    this.rating = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'author_avatar': authorAvatar,
      'content': content,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      author: json['author'] ?? json['author_details']?['username'] ?? '',
      authorAvatar: json['author_avatar'] ??
          json['author_details']?['avatar_path'] ??
          '',
      content: json['content'] ?? '',
      rating: (json['rating'] ?? json['author_details']?['rating'] ?? 0)
          .toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

class Genre {
  final String id;
  final String name;
  final String iconName;
  final String? imageUrl;

  const Genre({
    required this.id,
    required this.name,
    this.iconName = 'movie',
    this.imageUrl,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      iconName: json['icon_name'] ?? 'movie',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'image_url': imageUrl,
    };
  }

  static List<Genre> defaultGenres = const [
    Genre(id: '28', name: 'Action', iconName: 'local_fire_department'),
    Genre(id: '12', name: 'Adventure', iconName: 'explore'),
    Genre(id: '16', name: 'Animation', iconName: 'animation'),
    Genre(id: '35', name: 'Comedy', iconName: 'sentiment_very_satisfied'),
    Genre(id: '80', name: 'Crime', iconName: 'policy'),
    Genre(id: '99', name: 'Documentary', iconName: 'videocam'),
    Genre(id: '18', name: 'Drama', iconName: 'theater_comedy'),
    Genre(id: '10751', name: 'Family', iconName: 'family_restroom'),
    Genre(id: '14', name: 'Fantasy', iconName: 'auto_fix_high'),
    Genre(id: '36', name: 'History', iconName: 'history_edu'),
    Genre(id: '27', name: 'Horror', iconName: 'warning'),
    Genre(id: '10402', name: 'Music', iconName: 'music_note'),
    Genre(id: '9648', name: 'Mystery', iconName: 'search'),
    Genre(id: '10749', name: 'Romance', iconName: 'favorite'),
    Genre(id: '878', name: 'Science Fiction', iconName: 'rocket'),
    Genre(id: '10770', name: 'TV Movie', iconName: 'tv'),
    Genre(id: '53', name: 'Thriller', iconName: 'psychology'),
    Genre(id: '10752', name: 'War', iconName: 'military_tech'),
    Genre(id: '37', name: 'Western', iconName: 'landscape'),
  ];
}

class WatchlistItem {
  final String id;
  final String movieId;
  final String userId;
  final DateTime addedAt;
  final MovieContent? movie;

  const WatchlistItem({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.addedAt,
    this.movie,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id']?.toString() ?? '',
      movieId: json['movie_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'])
          : DateTime.now(),
      movie:
          json['movie'] != null ? MovieContent.fromJson(json['movie']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'user_id': userId,
      'added_at': addedAt.toIso8601String(),
    };
  }
}

class ContinueWatchingItem {
  final String id;
  final String movieId;
  final String userId;
  final int watchProgress; // in seconds
  final int totalDuration; // in seconds
  final DateTime lastWatchedAt;
  final MovieContent? movie;

  const ContinueWatchingItem({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.watchProgress,
    required this.totalDuration,
    required this.lastWatchedAt,
    this.movie,
  });

  double get progressPercent {
    if (totalDuration == 0) return 0;
    return (watchProgress / totalDuration) * 100;
  }

  String get remainingTime {
    final remaining = totalDuration - watchProgress;
    final minutes = remaining ~/ 60;
    if (minutes > 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m left';
    }
    return '${minutes}m left';
  }

  factory ContinueWatchingItem.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingItem(
      id: json['id']?.toString() ?? '',
      movieId: json['movie_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      watchProgress: json['watch_progress'] ?? 0,
      totalDuration: json['total_duration'] ?? 0,
      lastWatchedAt: json['last_watched_at'] != null
          ? DateTime.parse(json['last_watched_at'])
          : DateTime.now(),
      movie:
          json['movie'] != null ? MovieContent.fromJson(json['movie']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'user_id': userId,
      'watch_progress': watchProgress,
      'total_duration': totalDuration,
      'last_watched_at': lastWatchedAt.toIso8601String(),
    };
  }
}

class DownloadItem {
  final String id;
  final String movieId;
  final String userId;
  final String quality;
  final int fileSize; // in bytes
  final String localPath;
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final MovieContent? movie;

  const DownloadItem({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.quality,
    required this.fileSize,
    this.localPath = '',
    this.status = DownloadStatus.pending,
    this.progress = 0.0,
    required this.startedAt,
    this.completedAt,
    this.expiresAt,
    this.movie,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id']?.toString() ?? '',
      movieId: json['movie_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      quality: json['quality'] ?? '',
      fileSize: json['file_size'] ?? 0,
      localPath: json['local_path'] ?? '',
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.pending,
      ),
      progress: (json['progress'] ?? 0).toDouble(),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      movie:
          json['movie'] != null ? MovieContent.fromJson(json['movie']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'user_id': userId,
      'quality': quality,
      'file_size': fileSize,
      'local_path': localPath,
      'status': status.name,
      'progress': progress,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  DownloadItem copyWith({
    String? id,
    String? movieId,
    String? userId,
    String? quality,
    int? fileSize,
    String? localPath,
    DownloadStatus? status,
    double? progress,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? expiresAt,
    MovieContent? movie,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      userId: userId ?? this.userId,
      quality: quality ?? this.quality,
      fileSize: fileSize ?? this.fileSize,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      movie: movie ?? this.movie,
    );
  }
}

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  expired,
}

class SearchFilters {
  final String query;
  final List<String> genres;
  final int? yearFrom;
  final int? yearTo;
  final double? minRating;
  final String? sortBy; // popularity, rating, release_date, title
  final bool sortAscending;
  final String? contentType; // movie, tv, all
  final List<String> languages;

  const SearchFilters({
    this.query = '',
    this.genres = const [],
    this.yearFrom,
    this.yearTo,
    this.minRating,
    this.sortBy,
    this.sortAscending = false,
    this.contentType,
    this.languages = const [],
  });

  SearchFilters copyWith({
    String? query,
    List<String>? genres,
    int? yearFrom,
    int? yearTo,
    double? minRating,
    String? sortBy,
    bool? sortAscending,
    String? contentType,
    List<String>? languages,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      genres: genres ?? this.genres,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      contentType: contentType ?? this.contentType,
      languages: languages ?? this.languages,
    );
  }

  bool get hasFilters {
    return genres.isNotEmpty ||
        yearFrom != null ||
        yearTo != null ||
        minRating != null ||
        contentType != null ||
        languages.isNotEmpty;
  }

  int get activeFilterCount {
    int count = 0;
    if (genres.isNotEmpty) count++;
    if (yearFrom != null || yearTo != null) count++;
    if (minRating != null) count++;
    if (contentType != null) count++;
    if (languages.isNotEmpty) count++;
    return count;
  }
}
