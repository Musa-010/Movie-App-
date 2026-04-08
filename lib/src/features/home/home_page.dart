import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_navbar/liquid_glass_navbar.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../movies/movies_page.dart';
import '../auth/profile_page.dart';
import '../search/search_page.dart';
import '../watchlist/watchlist_page.dart';
import '../downloads/downloads_page.dart';

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
        SearchPage(),
        WatchlistPage(),
        DownloadsPage(),
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
