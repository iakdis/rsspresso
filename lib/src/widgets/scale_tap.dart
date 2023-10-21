import 'package:flutter/material.dart';

class ScaleTap extends StatefulWidget {
  const ScaleTap({
    super.key,
    required this.child,
    this.milliseconds = 75,
    this.lowerBound = 0.95,
    this.upperBound = 1.0,
  });

  final Widget child;
  final int milliseconds;
  final double lowerBound;
  final double upperBound;

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap> with TickerProviderStateMixin {
  double scale = 1;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      lowerBound: widget.lowerBound,
      upperBound: widget.upperBound,
      value: 1,
      duration: Duration(milliseconds: widget.milliseconds),
    );
    _controller.addListener(() => setState(() => scale = _controller.value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: GestureDetector(
        onTapDown: (dp) => _controller.reverse(),
        onTapUp: (dp) => _controller.fling(),
        onTapCancel: () => _controller.fling(),
        child: widget.child,
      ),
    );
  }
}
