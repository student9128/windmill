import 'package:flutter/material.dart';

class WindButton extends StatefulWidget {
  final Widget? child;
  final Function? onPressed;
  final Function? onLongPress;
  final double opacity;

  const WindButton({
    Key? key,
    this.onPressed,
    this.onLongPress,
    this.child,
    this.opacity=0.8
  }) : super(key: key);

  @override
  WindButtonState createState() => WindButtonState();
}

class WindButtonState extends State<WindButton> with TickerProviderStateMixin {
  bool _isChangeAlpha = false;

  AnimationController? _controller;
  late Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(value: 1, vsync: this);
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOutCubic,
    );
    _animation.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  bool _tapDown = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = const Duration(milliseconds: 50);
    Duration showDuration = const Duration(milliseconds: 660);

    return GestureDetector(
      onTap: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        widget.onPressed?.call();
      },
      onLongPress: widget.onLongPress == null
          ? null
          : () async {
        await Future.delayed(const Duration(milliseconds: 100));
        widget.onLongPress!();
      },
      onTapDown: (detail) async {
        _tapDown = true;
        _isChangeAlpha = true;
        await _controller!.animateTo(widget.opacity, duration: duration);
        if (!_tapDown) {
          await _controller!.animateTo(1, duration: showDuration);
        }
        _tapDown = false;
        _isChangeAlpha = false;
      },
      onTapUp: (detail) async {
        _tapDown = false;
        if (_isChangeAlpha == true) {
          return;
        }
        await _controller!.animateTo(1, duration: showDuration);
        _isChangeAlpha = false;
      },
      onTapCancel: () async {
        _tapDown = false;
        _controller!.value = 1;
        _isChangeAlpha = false;
      },
      child: Opacity(
        opacity: _animation.value,
        child: Container(
          color: const Color(0x00000000),
          child: widget.child,
        ),
      ),
    );
  }
}
