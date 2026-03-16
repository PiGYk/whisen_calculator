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
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// True when screen is wider than [breakpoint] (default 700px).
bool isWide(BuildContext context, [double breakpoint = 700]) =>
    MediaQuery.sizeOf(context).width > breakpoint;
