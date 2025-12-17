import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';

class AlertsBanner {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    hide();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (context) => _Banner(message: message),
    );

    overlay.insert(_entry!);
    Future<void>.delayed(duration, hide);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _Banner extends StatefulWidget {
  const _Banner({required this.message});

  final String message;

  @override
  State<_Banner> createState() => _BannerState();
}

class _BannerState extends State<_Banner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.cardSolid.withValues(alpha: 0.92),
                  border: Border.all(color: AppColors.separator),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.bolt_fill,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
