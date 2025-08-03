import 'package:flutter/material.dart';

class PoseImageWidget extends StatefulWidget {
  final String imageRef;
  final String imagePath;
  final bool isAnimated;

  const PoseImageWidget({
    Key? key,
    required this.imageRef,
    required this.imagePath,
    this.isAnimated = true,
  }) : super(key: key);

  @override
  State<PoseImageWidget> createState() => _PoseImageWidgetState();
}

class _PoseImageWidgetState extends State<PoseImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    if (widget.isAnimated) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PoseImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageRef != widget.imageRef && widget.isAnimated) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconForImage(String imageRef) {
    switch (imageRef.toLowerCase()) {
      case 'base':
        return Icons.self_improvement;
      case 'cat':
        return Icons.pets;
      case 'cow':
        return Icons.agriculture;
      case 'mountain':
        return Icons.landscape;
      case 'tree':
        return Icons.park;
      case 'warrior':
        return Icons.fitness_center;
      case 'child':
        return Icons.child_care;
      default:
        return Icons.self_improvement;
    }
  }

  Color _getColorForImage(String imageRef) {
    switch (imageRef.toLowerCase()) {
      case 'cat':
        return const Color(0xFF9C27B0);
      case 'cow':
        return const Color(0xFF795548);
      case 'base':
        return const Color(0xFF667eea);
      default:
        return const Color(0xFF667eea);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isAnimated ? _scaleAnimation.value : 1.0,
          child: Opacity(
            opacity: widget.isAnimated ? _opacityAnimation.value : 1.0,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: _getColorForImage(widget.imageRef).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getColorForImage(widget.imageRef),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getColorForImage(widget.imageRef).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForImage(widget.imageRef),
                    size: 80,
                    color: _getColorForImage(widget.imageRef),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.imageRef.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getColorForImage(widget.imageRef),
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
}