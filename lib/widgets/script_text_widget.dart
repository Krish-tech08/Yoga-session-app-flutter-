import 'package:flutter/material.dart';

class ScriptTextWidget extends StatefulWidget {
  final String text;
  final bool isAnimated;

  const ScriptTextWidget({
    Key? key,
    required this.text,
    this.isAnimated = true,
  }) : super(key: key);

  @override
  State<ScriptTextWidget> createState() => _ScriptTextWidgetState();
}

class _ScriptTextWidgetState extends State<ScriptTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.isAnimated) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ScriptTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text && widget.isAnimated) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: widget.isAnimated ? _slideAnimation :
          const AlwaysStoppedAnimation(Offset.zero),
          child: FadeTransition(
            opacity: widget.isAnimated ? _fadeAnimation :
            const AlwaysStoppedAnimation(1.0),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Color(0xFF333333),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}