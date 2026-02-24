import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/sign_in_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _shimmerController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shimmerAnimation;

  bool _navigated = false;
  bool _minimumTimeElapsed = false;
  bool _authResolved = false;

  @override
  void initState() {
    super.initState();

    // Fade in/out controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Scale with elastic bounce
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Shimmer sweep
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Start entrance animations
    _fadeController.forward();
    _scaleController.forward();

    // Delay then run shimmer
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _shimmerController.forward();

    // Ensure minimum splash duration of 2 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    _minimumTimeElapsed = true;
    _tryNavigate();
  }

  Future<void> _tryNavigate() async {
    if (_navigated || !_minimumTimeElapsed || !_authResolved || !mounted) return;
    _navigated = true;

    // Fade out
    await _fadeController.reverse();
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final destination = auth.isAuthenticated
        ? const HomeScreen()
        : const SignInScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoading && !_authResolved) {
      _authResolved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryNavigate());
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleController, _shimmerController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: const [
                        Colors.white,
                        Color(0xCCFFFFFF),
                        Colors.white,
                      ],
                      stops: [
                        (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                        _shimmerAnimation.value.clamp(0.0, 1.0),
                        (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: child!,
                ),
              );
            },
            child: Image.asset(
              'assets/images/bidsrush_logo.png',
              width: 220,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
