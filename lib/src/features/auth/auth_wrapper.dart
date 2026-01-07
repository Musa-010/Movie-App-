import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../home/home_page.dart';
import '../landing/landing_page.dart';
import '../onboarding/onboarding_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasSeenLanding = false;
  bool _hasSeenOnboarding = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenLanding = prefs.getBool('hasSeenLanding') ?? false;
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _setLandingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenLanding', true);
    setState(() {
      _hasSeenLanding = true;
    });
  }

  Future<void> _setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    setState(() {
      _hasSeenOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show loading while checking
    if (_isLoading || authProvider.status == AuthStatus.initial) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF006BF3)),
        ),
      );
    }

    // Show landing page if not seen before
    if (!_hasSeenLanding) {
      return LandingPage(
        onGetStarted: () {
          _setLandingSeen();
        },
      );
    }

    // Show onboarding page if not seen before
    if (!_hasSeenOnboarding) {
      return OnboardingPage(
        onComplete: () {
          _setOnboardingSeen();
        },
        onSkip: () {
          _setOnboardingSeen();
        },
      );
    }

    // Navigate based on auth status
    if (authProvider.isLoggedIn) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
