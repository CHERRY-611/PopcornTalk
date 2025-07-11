import 'package:flutter/material.dart';

class SplashOverlay extends StatefulWidget {
  final Duration duration;

  const SplashOverlay({super.key, this.duration = const Duration(seconds: 2)});

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Container(
      color: const Color(0xFFE66161),
      child: Center(
        child: Image.asset('assets/splash.png', width: 180),
      ),
    );
  }
}
