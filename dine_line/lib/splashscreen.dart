// file: lib/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _textFadeAnimation;

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // We now need a list of animations, one for each dot.
  final List<Animation<double>> _dotJumpAnimations = [];
  final int _dotCount = 7;
  final int _staggerDelayMs = 50;
  final int _singleDotJumpDurationMs = 400;

  @override
  void initState() {
    super.initState();

    // Start playing music immediately

    // Calculate the total duration needed for the entire animation sequence.
    final int textAnimationDurationMs = 1500;
    final int totalDotSequenceDurationMs = (_dotCount - 1) * _staggerDelayMs + _singleDotJumpDurationMs;
    final int totalDurationMs = textAnimationDurationMs + totalDotSequenceDurationMs;

    _controller = AnimationController(
      duration: Duration(milliseconds: totalDurationMs),
      vsync: this,
    );

    // --- Text Animations (Occur during the first 1500ms) ---
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1500 / totalDurationMs, curve: Curves.easeOut),
      ),
    );

    _textScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 1500 / totalDurationMs, curve: Curves.easeOutQuint),
    );

    // --- Staggered Dot Animations ---
    for (double i = 0; i < _dotCount; i++) {
      final double startTimeMs = textAnimationDurationMs + (i * _staggerDelayMs);
      final double endTimeMs = startTimeMs + _singleDotJumpDurationMs;

      final Interval dotInterval = Interval(
        startTimeMs / totalDurationMs,
        endTimeMs / totalDurationMs,
      );

      final Animation<double> jumpAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
        TweenSequenceItem(tween: Tween(begin: -20.0, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 50),
      ]).animate(
        CurvedAnimation(parent: _controller, curve: dotInterval),
      );

      _dotJumpAnimations.add(jumpAnimation);
    }

    // Start the whole animation sequence
    _controller.forward();
    Timer(Duration(milliseconds: 500), () {
      if (mounted) _playBackgroundMusic();
    });
    // Navigate to the home page after the full animation is done.
    Timer(Duration(milliseconds: totalDurationMs + 500), () {
      if (mounted) {
        _stopBackgroundMusic(); // Stop music before navigating
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  // Play background music
  Future<void> _playBackgroundMusic() async {
    try {
      // You can use different methods depending on your audio file location:

      // For assets (recommended):
      await _audioPlayer.play(AssetSource('audio/Dineline.wav'));

      // Optional: Set volume (0.0 to 1.0)
      await _audioPlayer.setVolume(0.7);

      // Optional: Set playback mode (if you want it to loop)
      // await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    } catch (e) {
      // Handle any errors (e.g., file not found)
      print('Error playing audio: $e');
    }
  }

  // Stop background music
  Future<void> _stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose(); // Don't forget to dispose the audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The "Dineline" text animation (unchanged)
            FadeTransition(
              opacity: _textFadeAnimation,
              child: ScaleTransition(
                scale: _textScaleAnimation,
                child: const Text(
                  'Dineline',
                  style: TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F4293),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // The staggered dots animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_dotCount, (index) {
                return AnimatedBuilder(
                  animation: _dotJumpAnimations[index],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _dotJumpAnimations[index].value),
                      child: child,
                    );
                  },
                  child: _buildDot(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: 10.0,
      height: 10.0,
      decoration: const BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
      ),
    );
  }
}