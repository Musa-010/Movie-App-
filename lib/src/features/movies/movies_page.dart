import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/providers/theme_provider.dart';
import 'widgets/widgets.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main content with TabBarView
          Positioned.fill(
            child: Column(
              children: [
                // Space for the glass app bar
                SizedBox(height: statusBarHeight + kToolbarHeight + 48),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      MoviesView(),
                      SeriesView(),
                      TvShowView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Liquid Glass Status Bar & App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.04),
                            ]
                          : [
                              Colors.white.withOpacity(0.85),
                              Colors.white.withOpacity(0.75),
                              Colors.white.withOpacity(0.65),
                            ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.08),
                        width: 0.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Bar content
                        SizedBox(
                          height: kToolbarHeight,
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              // Title
                              Expanded(
                                child: Text(
                                  'StreamTix',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: isDark ? Colors.white : Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Theme toggle button with glass effect
                              _buildGlassIconButton(
                                isDark: isDark,
                                icon: isDark ? Iconsax.sun_15 : Iconsax.moon5,
                                iconColor: isDark ? Colors.amber : Colors.blueGrey,
                                onPressed: () => themeProvider.toggleTheme(),
                                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                        // Tab Bar with glass effect
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicator: const DotIndicator(),
                          labelColor: isDark ? Colors.white : Colors.black,
                          unselectedLabelColor: isDark 
                              ? Colors.white.withOpacity(0.5) 
                              : Colors.black.withOpacity(0.5),
                          tabs: const [
                            Tab(text: 'Movie'),
                            Tab(text: 'Series'),
                            Tab(text: 'TV Show'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              icon,
              key: ValueKey(isDark),
              color: iconColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
