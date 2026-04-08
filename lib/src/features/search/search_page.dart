import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/models/movie_content.dart';
import '../../core/providers/movie_content_provider.dart';
import '../movie_details/movie_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieContentProvider>().loadGenres();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<MovieContentProvider>().searchMovies(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Search',
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
              final filterCount = provider.searchFilters.activeFilterCount;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () =>
                        setState(() => _showFilters = !_showFilters),
                    icon: Icon(
                      Iconsax.filter,
                      color: _showFilters
                          ? const Color(0xFF006BF3)
                          : (isDark ? Colors.white70 : Colors.grey.shade700),
                    ),
                  ),
                  if (filterCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF006BF3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            filterCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSearchBar(isDark),
          ),

          // Filter section
          if (_showFilters) _buildFilterSection(isDark),

          // Content
          Expanded(
            child: Consumer<MovieContentProvider>(
              builder: (context, provider, child) {
                if (_searchController.text.isEmpty) {
                  return _buildInitialState(provider, isDark);
                }

                if (provider.isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.searchResults.isEmpty) {
                  return _buildNoResultsState(isDark);
                }

                return _buildSearchResults(provider.searchResults, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Search movies, series, actors...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: Colors.grey.shade500,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<MovieContentProvider>().clearSearch();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade500,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() {});
          _onSearchChanged(value);
        },
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.read<MovieContentProvider>().searchMovies(value);
          }
        },
      ),
    );
  }

  Widget _buildFilterSection(bool isDark) {
    return Consumer<MovieContentProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Genre chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.genres.length,
                  itemBuilder: (context, index) {
                    final genre = provider.genres[index];
                    final isSelected =
                        provider.searchFilters.genres.contains(genre.id);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(genre.name),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        backgroundColor:
                            isDark ? Colors.white.withAlpha(13) : Colors.grey.shade100,
                        selectedColor: const Color(0xFF006BF3),
                        checkmarkColor: Colors.white,
                        onSelected: (selected) {
                          final genres = List<String>.from(
                              provider.searchFilters.genres);
                          if (selected) {
                            genres.add(genre.id);
                          } else {
                            genres.remove(genre.id);
                          }
                          provider.updateSearchFilters(
                            provider.searchFilters.copyWith(genres: genres),
                          );
                          if (_searchController.text.isNotEmpty) {
                            provider.searchMovies(_searchController.text);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Additional filters row
              Row(
                children: [
                  // Rating filter
                  Expanded(
                    child: _buildFilterDropdown(
                      'Rating',
                      provider.searchFilters.minRating?.toString() ?? 'Any',
                      ['Any', '7+', '8+', '9+'],
                      (value) {
                        double? rating;
                        if (value != 'Any') {
                          rating = double.parse(value!.replaceAll('+', ''));
                        }
                        provider.updateSearchFilters(
                          provider.searchFilters.copyWith(minRating: rating),
                        );
                        if (_searchController.text.isNotEmpty) {
                          provider.searchMovies(_searchController.text);
                        }
                      },
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Year filter
                  Expanded(
                    child: _buildFilterDropdown(
                      'Year',
                      provider.searchFilters.yearFrom?.toString() ?? 'Any',
                      [
                        'Any',
                        '2024',
                        '2023',
                        '2022',
                        '2020s',
                        '2010s',
                        '2000s',
                      ],
                      (value) {
                        int? yearFrom;
                        int? yearTo;
                        if (value == '2024') {
                          yearFrom = 2024;
                          yearTo = 2024;
                        } else if (value == '2023') {
                          yearFrom = 2023;
                          yearTo = 2023;
                        } else if (value == '2022') {
                          yearFrom = 2022;
                          yearTo = 2022;
                        } else if (value == '2020s') {
                          yearFrom = 2020;
                          yearTo = 2029;
                        } else if (value == '2010s') {
                          yearFrom = 2010;
                          yearTo = 2019;
                        } else if (value == '2000s') {
                          yearFrom = 2000;
                          yearTo = 2009;
                        }
                        provider.updateSearchFilters(
                          provider.searchFilters.copyWith(
                            yearFrom: yearFrom,
                            yearTo: yearTo,
                          ),
                        );
                        if (_searchController.text.isNotEmpty) {
                          provider.searchMovies(_searchController.text);
                        }
                      },
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Clear filters button
              if (provider.searchFilters.hasFilters)
                TextButton.icon(
                  onPressed: () {
                    provider.clearSearchFilters();
                    if (_searchController.text.isNotEmpty) {
                      provider.searchMovies(_searchController.text);
                    }
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade500,
          ),
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                '$label: $option',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInitialState(MovieContentProvider provider, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (provider.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () => provider.clearRecentSearches(),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.recentSearches.map((query) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = query;
                    setState(() {});
                    provider.searchMovies(query);
                  },
                  child: Chip(
                    label: Text(query),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withAlpha(13)
                        : Colors.grey.shade100,
                    deleteIcon: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    onDeleted: () => provider.removeRecentSearch(query),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Trending searches
          Text(
            'Trending',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...['The Dark Knight', 'Inception', 'Interstellar', 'Pulp Fiction']
              .map((title) {
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(13)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF006BF3),
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade500,
              ),
              onTap: () {
                _searchController.text = title;
                setState(() {});
                provider.searchMovies(title);
              },
            );
          }),

          const SizedBox(height: 24),

          // Browse by genre
          Text(
            'Browse by Genre',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.genres.take(8).length,
            itemBuilder: (context, index) {
              final genre = provider.genres[index];
              return _GenreCard(
                genre: genre,
                isDark: isDark,
                onTap: () {
                  provider.updateSearchFilters(
                    provider.searchFilters.copyWith(genres: [genre.id]),
                  );
                  _searchController.text = genre.name;
                  setState(() {});
                  provider.searchMovies(genre.name);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_status,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<MovieContent> results, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final movie = results[index];
        return _SearchResultCard(
          movie: movie,
          isDark: isDark,
        );
      },
    );
  }
}

class _GenreCard extends StatelessWidget {
  final Genre genre;
  final bool isDark;
  final VoidCallback onTap;

  const _GenreCard({
    required this.genre,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF006BF3).withAlpha(179),
              const Color(0xFF006BF3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            genre.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final MovieContent movie;
  final bool isDark;

  const _SearchResultCard({
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade50,
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
                width: 80,
                height: 120,
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
                    const SizedBox(height: 6),
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
                        if (movie.voteCount > 0) ...[
                          Text(
                            ' (${_formatVoteCount(movie.voteCount)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (movie.genres.isNotEmpty)
                      Text(
                        movie.genres.take(3).join(', '),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),

            // Play button
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF006BF3).withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF006BF3),
                ),
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

  String _formatVoteCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
