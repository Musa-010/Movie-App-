import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A liquid glass effect app bar with frosted blur effect
class LiquidGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool isDarkMode;
  final double blurStrength;
  final double opacity;

  const LiquidGlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.isDarkMode = false,
    this.blurStrength = 20.0,
    this.opacity = 0.7,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurStrength,
          sigmaY: blurStrength,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ]
                  : [
                      Colors.white.withOpacity(opacity),
                      Colors.white.withOpacity(opacity * 0.8),
                      Colors.white.withOpacity(opacity * 0.6),
                    ],
            ),
            border: Border(
              bottom: BorderSide(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      if (title != null) Expanded(child: title!),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A more advanced liquid glass container with animated shimmer effect
class LiquidGlassContainer extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;
  final double blurStrength;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool enableShimmer;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.isDarkMode = false,
    this.blurStrength = 15.0,
    this.borderRadius,
    this.padding,
    this.enableShimmer = true,
  });

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    if (widget.enableShimmer) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurStrength,
          sigmaY: widget.blurStrength,
        ),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isDarkMode
                      ? [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.05),
                        ]
                      : [
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.6),
                          Colors.white.withOpacity(0.4),
                        ],
                ),
                border: Border.all(
                  color: widget.isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                  // Inner glow
                  BoxShadow(
                    color: widget.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: -2,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer effect overlay
                  if (widget.enableShimmer)
                    Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: [
                              (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                              _shimmerAnimation.value.clamp(0.0, 1.0),
                              (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                            ],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                widget.borderRadius ?? BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  widget.child,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A status bar overlay with liquid glass effect
class LiquidGlassStatusBar extends StatelessWidget {
  final bool isDarkMode;
  final double blurStrength;

  const LiquidGlassStatusBar({
    super.key,
    this.isDarkMode = false,
    this.blurStrength = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: statusBarHeight,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurStrength,
            sigmaY: blurStrength,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                      ]
                    : [
                        Colors.white.withOpacity(0.8),
                        Colors.white.withOpacity(0.5),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
