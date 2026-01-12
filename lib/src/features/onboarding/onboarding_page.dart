import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/constants.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const OnboardingPage({super.key, this.onComplete, this.onSkip});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonPulseController;
  late AnimationController _imageFloatController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonPulseAnimation;
  late Animation<double> _imageFloatAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      boldText1: 'Discover',
      lightText1: 'Your Next',
      boldText2: 'Favorite',
      lightText2: 'Movie',
      description:
          'Browse thousands of movies, find what you love, and never miss a blockbuster.',
      imageType: ImageType.movieCards,
    ),
    OnboardingData(
      boldText1: 'Book',
      lightText1: 'Tickets With',
      boldText2: 'Quick',
      lightText2: 'Ease 🎟️',
      description:
          'Get your seats in seconds, skip the lines, and enjoy the show.',
      imageType: ImageType.personWithHeadphones,
    ),
    OnboardingData(
      boldText1: 'Stay',
      lightText1: 'Entertained And',
      boldText2: 'Achieve',
      lightText2: 'Goals 🎬',
      description: 'Stream anytime, anywhere. Your entertainment, your way.',
      imageType: ImageType.streaming,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _buttonPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _buttonPulseController, curve: Curves.easeInOut),
    );

    _imageFloatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _imageFloatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _imageFloatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _buttonPulseController.dispose();
    _imageFloatController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete?.call();
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          _buildBackground(),

          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8EEFF), Color(0xFFF5F7FF), Colors.white],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return SafeArea(
      child: Column(
        children: [
          // Top image area
          Expanded(
            flex: 5,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildImageSection(data.imageType),
            ),
          ),

          // Bottom text area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Title with mixed weights
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 32,
                            height: 1.2,
                            color: Color(0xFF1A1A2E),
                          ),
                          children: [
                            TextSpan(
                              text: '${data.boldText1} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: data.lightText1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 32,
                            height: 1.2,
                            color: Color(0xFF1A1A2E),
                          ),
                          children: [
                            TextSpan(
                              text: '${data.boldText2} ',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            TextSpan(
                              text: data.lightText2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        data.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Space for bottom controls
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildImageSection(ImageType type) {
    return AnimatedBuilder(
      animation: _imageFloatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _imageFloatAnimation.value),
          child: Center(child: _buildImageForType(type)),
        );
      },
    );
  }

  Widget _buildImageForType(ImageType type) {
    switch (type) {
      case ImageType.movieCards:
        return _buildMovieCardsImage();
      case ImageType.personWithHeadphones:
        return _buildPersonImage();
      case ImageType.streaming:
        return _buildStreamingImage();
    }
  }

  Widget _buildMovieCardsImage() {
    return SizedBox(
      width: 300,
      height: 350,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back card
          Positioned(
            right: 20,
            top: 30,
            child: Transform.rotate(
              angle: 0.15,
              child: Container(
                width: 160,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey.shade200, Colors.grey.shade100],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Front card
          Positioned(
            left: 20,
            top: 60,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 180,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Floating elements
          Positioned(
            right: 40,
            bottom: 60,
            child: _buildFloatingIcon(
              Icons.star_rounded,
              const Color(0xFFFFD700),
            ),
          ),
          Positioned(
            left: 50,
            top: 20,
            child: _buildFloatingIcon(
              Icons.movie_filter_rounded,
              AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonImage() {
    return SizedBox(
      width: 320,
      height: 380,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Positioned(
            top: 40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.15),
                    AppColors.primaryColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Person silhouette with headphones
          Center(
            child: Container(
              width: 200,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.8),
                    AppColors.primaryColor,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Head with headphones
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      // Headphones
                      Positioned(
                        top: -5,
                        child: Icon(
                          Icons.headphones_rounded,
                          size: 90,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Icon(
                    Icons.music_note_rounded,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
          // Floating elements
          Positioned(
            right: 20,
            top: 80,
            child: _buildFloatingIcon(
              Icons.confirmation_number_outlined,
              AppColors.primaryColor,
            ),
          ),
          Positioned(
            left: 30,
            bottom: 80,
            child: _buildFloatingIcon(
              Icons.local_movies_rounded,
              const Color(0xFFFF6B6B),
            ),
          ),
          Positioned(
            right: 50,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_rounded,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tickets',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamingImage() {
    return SizedBox(
      width: 320,
      height: 380,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Streaming visual
          Center(
            child: Container(
              width: 220,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.9),
                    AppColors.primaryColor,
                    const Color(0xFF004EC4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play button
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const Expanded(flex: 4, child: SizedBox()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '1:23:45',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '2:15:00',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
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
          ),
          // Floating elements
          Positioned(
            left: 20,
            top: 40,
            child: _buildFloatingIcon(
              Icons.hd_rounded,
              const Color(0xFFFFD700),
            ),
          ),
          Positioned(
            right: 20,
            top: 100,
            child: _buildFloatingIcon(Icons.download_rounded, Colors.green),
          ),
          Positioned(
            left: 40,
            bottom: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '4K',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Ultra HD',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Skip button
            GestureDetector(
              onTap: widget.onSkip ?? widget.onComplete,
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            // Page indicators
            _buildPageIndicators(),
            // Next button
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPage == index
                ? AppColors.primaryColor
                : AppColors.primaryColor.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return AnimatedBuilder(
      animation: _buttonPulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _nextPage,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(
                    alpha: 0.3 + (_buttonPulseAnimation.value - 1) * 2,
                  ),
                  blurRadius: 20,
                  spreadRadius: (_buttonPulseAnimation.value - 1) * 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        );
      },
    );
  }
}

class OnboardingData {
  final String boldText1;
  final String lightText1;
  final String boldText2;
  final String lightText2;
  final String description;
  final ImageType imageType;

  OnboardingData({
    required this.boldText1,
    required this.lightText1,
    required this.boldText2,
    required this.lightText2,
    required this.description,
    required this.imageType,
  });
}

enum ImageType { movieCards, personWithHeadphones, streaming }
