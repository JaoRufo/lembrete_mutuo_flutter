import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (ctx, anim, secondary) => const HomeScreen(),
          transitionsBuilder: (ctx, anim, secondary, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F1A), Color(0xFF1A1A3E), Color(0xFF0F0F1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (ctx, child) => Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1A1A2E),
                        border: Border.all(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6C63FF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Image.asset(
                        'lib/assets/logo-lembrete-mutuo-new.png',
                        errorBuilder: (ctx, err, stack) => const Icon(
                          Icons.monetization_on,
                          color: Color(0xFF6C63FF),
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _controller,
                builder: (ctx, child) => Opacity(
                  opacity: _textFade.value,
                  child: Column(
                    children: [
                      const Text(
                        'Lembrete Mútuo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Controle de pagamentos',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
