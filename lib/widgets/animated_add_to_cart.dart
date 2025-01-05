// lib/widgets/animated_add_to_cart.dart
import 'package:flutter/material.dart';

class AddToCartAnimation extends StatefulWidget {
  final Widget child;
  final Function() onTap;
  final GlobalKey cartKey;

  const AddToCartAnimation({
    Key? key,
    required this.child,
    required this.onTap,
    required this.cartKey,
  }) : super(key: key);

  @override
  State<AddToCartAnimation> createState() => _AddToCartAnimationState();
}

class _AddToCartAnimationState extends State<AddToCartAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _moveToCartAnimation;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 80,
      ),
    ]).animate(_controller);

    _moveToCartAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInQuad,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _controller.reset();
        widget.onTap();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _createAddToCartAnimation(BuildContext context) {
    // Get the positions
    final RenderBox box = context.findRenderObject() as RenderBox;
    final productPosition = box.localToGlobal(Offset.zero);
    final productSize = box.size;

    final RenderBox cartBox = widget.cartKey.currentContext!.findRenderObject() as RenderBox;
    final cartPosition = cartBox.localToGlobal(Offset.zero);

    // Create the overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double dx = _moveToCartAnimation.value * 
              (cartPosition.dx - productPosition.dx);
          final double dy = _moveToCartAnimation.value * 
              (cartPosition.dy - productPosition.dy);

          return Positioned(
            left: productPosition.dx + dx,
            top: productPosition.dy + dy,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                width: productSize.width,
                height: productSize.height,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _createAddToCartAnimation(context),
      child: widget.child,
    );
  }
}