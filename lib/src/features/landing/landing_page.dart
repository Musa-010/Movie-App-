import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/constants.dart';

class LandingPage extends StatefulWidget {
  final VoidCallback? onGetStarted;

  const LandingPage({super.key, this.onGetStarted});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _cardController;

  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // 3D Rotation controller
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Card stagger animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background with mesh effect
          _buildAnimatedBackground(),

          // Floating particles
          _buildParticles(),

          // 3D rotating rings with glow
          _build3DRings(),

          // Light rays effect
          _buildLightRays(),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 3D Logo with floating animation
                  _build3DLogo(),

                  const SizedBox(height: 40),

                  // App name with glow effect
                  _buildAppName(),

                  const SizedBox(height: 16),

                  // Tagline with shimmer
                  _buildTagline(),

                  const Spacer(flex: 3),

                  // Feature cards with stagger animation
                  _buildFeatureCards(),

                  const Spacer(flex: 2),

                  // Get Started button with ripple effect
                  _buildGetStartedButton(),

                  const SizedBox(height: 20),

                  // Terms text
                  _buildTermsText(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0A1628),
                  const Color(0xFF0D2240),
                  (_rotationController.value * 2).clamp(0.0, 1.0),
                )!,
                const Color(0xFF0A1628),
                Color.lerp(
                  const Color(0xFF0D2240),
                  const Color(0xFF061220),
                  ((_rotationController.value - 0.5).abs() * 2).clamp(0.0, 1.0),
                )!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: MeshGradientPainter(animation: _rotationController.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildLightRays() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return CustomPaint(
          painter: LightRaysPainter(animation: _rotationController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(animation: _particleController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _build3DRings() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Center(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_rotationController.value * 2 * math.pi * 0.3)
              ..rotateY(_rotationController.value * 2 * math.pi),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring with glow
                _buildGlowRing(320, AppColors.primaryColor.withValues(alpha: 0.15), 2.5),
                // Middle ring
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateZ(_rotationController.value * math.pi),
                  child: _buildGlowRing(260, const Color(0xFF00A8E8).withValues(alpha: 0.12), 2),
                ),
                // Inner ring
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateZ(-_rotationController.value * 2 * math.pi),
                  child: _buildGlowRing(200, const Color(0xFF4FC3F7).withValues(alpha: 0.1), 1.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowRing(double size, Color color, double width) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: width),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _build3DLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _pulseAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF004EC4),
                        Color(0xFF006BF3),
                        Color(0xFF00A8E8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.6),
                        blurRadius: 50,
                        spreadRadius: 15,
                      ),
                      BoxShadow(
                        color: const Color(0xFF00A8E8).withValues(alpha: 0.4),
                        blurRadius: 70,
                        spreadRadius: 25,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated glow effect
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(38),
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.2 * _pulseAnimation.value),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // 3D effect layers
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Play icon with shadow
                      Transform.translate(
                        offset: const Offset(3, 0),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 80,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      // Ticket overlay with animation
                      Positioned(
                        bottom: 22,
                        right: 22,
                        child: AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, math.sin(_floatController.value * 2 * math.pi) * 3),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.confirmation_number_outlined,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFF004EC4),
                  Color(0xFF006BF3),
                  Color(0xFF00A8E8),
                  Color(0xFF4FC3F7),
                  Color(0xFF00A8E8),
                  Color(0xFF006BF3),
                ],
                stops: [
                  0.0,
                  _shimmerAnimation.value.clamp(0.0, 1.0),
                  (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                  (_shimmerAnimation.value + 0.5).clamp(0.0, 1.0),
                  (_shimmerAnimation.value + 0.7).clamp(0.0, 1.0),
                  1.0,
                ],
              ).createShader(bounds),
              child: const Text(
                'StreamTix',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: Color(0xFF004EC4),
                      offset: Offset(0, 4),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.5),
                ],
                stops: [
                  0.0,
                  (_shimmerAnimation.value + 1).clamp(0.0, 1.0),
                  1.0,
                ],
              ).createShader(bounds),
              child: const Text(
                'Stream Movies • Book Tickets • Anytime',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureCard(
          icon: Icons.movie_filter_rounded,
          title: '10K+',
          subtitle: 'Movies',
          color: AppColors.primaryColor,
          delay: 0,
        ),
        _buildFeatureCard(
          icon: Icons.hd_rounded,
          title: '4K',
          subtitle: 'Quality',
          color: const Color(0xFF00A8E8),
          delay: 150,
        ),
        _buildFeatureCard(
          icon: Icons.offline_bolt_rounded,
          title: 'Offline',
          subtitle: 'Download',
          color: const Color(0xFF4FC3F7),
          delay: 300,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
  }) {
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Interval(
          delay / 1800,
          (delay + 600) / 1800,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGetStartedButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {
            if (widget.onGetStarted != null) {
              widget.onGetStarted!();
            }
          },
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF004EC4),
                      Color(0xFF006BF3),
                      Color(0xFF00A8E8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(
                        alpha: 0.4 + (_pulseAnimation.value - 1) * 3,
                      ),
                      blurRadius: 25 + (_pulseAnimation.value - 1) * 40,
                      spreadRadius: (_pulseAnimation.value - 1) * 15,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shimmer effect
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: CustomPaint(
                              painter: ButtonShimmerPainter(
                                animation: _shimmerController.value,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'By continuing, you agree to our Terms of Service',
        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
      ),
    );
  }
}

// Enhanced Particle Painter
class ParticlePainter extends CustomPainter {
  final double animation;

  ParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Skip painting if size is zero or invalid
    if (size.width <= 0 || size.height <= 0) return;
    
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final y = (baseY - animation * size.height * speed) % size.height;

      final opacity = 0.15 + random.nextDouble() * 0.35;
      final radius = 1.5 + random.nextDouble() * 2.5;

      final colorIndex = i % 3;
      final colors = [
        const Color(0xFF004EC4),
        const Color(0xFF006BF3),
        const Color(0xFF00A8E8),
      ];

      paint.color = colors[colorIndex].withValues(alpha: opacity);
      
      // Add glow effect
      canvas.drawCircle(Offset(x, y), radius + 2, paint..color = colors[colorIndex].withValues(alpha: opacity * 0.3));
      canvas.drawCircle(Offset(x, y), radius, paint..color = colors[colorIndex].withValues(alpha: opacity));
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// Mesh Gradient Painter for background
class MeshGradientPainter extends CustomPainter {
  final double animation;

  MeshGradientPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = (size.width * (i / 5)) + math.sin(animation * math.pi * 2 + i) * 100;
      final y = size.height * 0.3 + math.cos(animation * math.pi * 2 + i * 0.7) * 150;

      paint.color = const Color(0xFF004EC4).withValues(alpha: 0.03);
      canvas.drawCircle(Offset(x, y), 150, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MeshGradientPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// Light Rays Painter
class LightRaysPainter extends CustomPainter {
  final double animation;

  LightRaysPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final center = Offset(size.width / 2, size.height * 0.3);

    for (int i = 0; i < 8; i++) {
      final angle = (animation * 2 * math.pi) + (i * math.pi / 4);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(angle) * 300,
          center.dy + math.sin(angle) * 300,
        )
        ..lineTo(
          center.dx + math.cos(angle + 0.1) * 300,
          center.dy + math.sin(angle + 0.1) * 300,
        )
        ..close();

      paint.color = const Color(0xFF006BF3).withValues(alpha: 0.02);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LightRaysPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// Button Shimmer Painter
class ButtonShimmerPainter extends CustomPainter {
  final double animation;

  ButtonShimmerPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: [
          (animation - 0.3).clamp(0.0, 1.0),
          animation.clamp(0.0, 1.0),
          (animation + 0.3).clamp(0.0, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant ButtonShimmerPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}