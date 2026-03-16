import 'package:flutter/material.dart';

/// Constrains body content to [maxWidth] and centers it.
/// Works on both mobile (content fills naturally) and desktop (centered, bounded).
class WebFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const WebFrame({
    super.key,
    required this.child,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final h = constraints.maxHeight;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: h.isFinite ? h : 0,
              maxHeight: h.isFinite ? h : double.infinity,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// True when screen is wider than [breakpoint] (default 700px).
bool isWide(BuildContext context, [double breakpoint = 700]) =>
    MediaQuery.sizeOf(context).width > breakpoint;
