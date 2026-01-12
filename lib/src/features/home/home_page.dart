import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liquid_glass_navbar/liquid_glass_navbar.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../movies/movies_page.dart';
import '../auth/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    // Set system UI overlay style for liquid glass effect
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return LiquidGlassNavBar(
      currentIndex: _currentIndex,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      pages: const [
        MoviesPage(),
        _SearchPage(),
        _WatchlistPage(),
        _DownloadsPage(),
        ProfilePage(),
      ],
      items: const [
        LiquidGlassNavItem(icon: Icons.home_rounded, label: 'Home'),
        LiquidGlassNavItem(icon: Icons.search_rounded, label: 'Search'),
        LiquidGlassNavItem(icon: Icons.favorite_rounded, label: 'Watchlist'),
        LiquidGlassNavItem(icon: Icons.download_rounded, label: 'Downloads'),
        LiquidGlassNavItem(icon: Icons.person_rounded, label: 'Profile'),
      ],
      backgroundColor: Colors.white,
      itemColor: isDark ? Colors.white : Colors.black,
      bubbleColor: Colors.white,
      backgroundOpacity: isDark ? 0.15 : 0.6,
      bubbleOpacity: isDark ? 0.2 : 0.4,
      blurStrength: 15.0,
      height: 60,
      borderRadius: 30,
      bubbleWidth: 60,
      bubbleHeight: 50,
      iconSize: 22,
      fontSize: 10,
    );
  }
}

// Placeholder pages - you can expand these later
class _SearchPage extends StatelessWidget {
  const _SearchPage();

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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_normal,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for movies, series & TV shows',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistPage extends StatelessWidget {
  const _WatchlistPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Watchlist',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
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
              'Your watchlist is empty',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadsPage extends StatelessWidget {
  const _DownloadsPage();

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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_download,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No downloads yet',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
