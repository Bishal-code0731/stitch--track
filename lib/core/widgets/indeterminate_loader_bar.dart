import 'package:flutter/material.dart';

import '../theme/colors.dart';

class IndeterminateLoaderBar extends StatefulWidget {
  const IndeterminateLoaderBar({this.width = 150, super.key});

  final double width;

  @override
  State<IndeterminateLoaderBar> createState() => _IndeterminateLoaderBarState();
}

class _IndeterminateLoaderBarState extends State<IndeterminateLoaderBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationStarted) return;
    _animationStarted = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = const Duration(milliseconds: 1600);
    }
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.14),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              return Align(
                alignment: Alignment(-1 + t * 2.76, 0),
                child: FractionallySizedBox(
                  widthFactor: 0.38,
                  child: Container(color: AppColors.amber),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
