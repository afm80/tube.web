import 'package:flutter/material.dart';

import '../config.dart';
import '../utils.dart';
import 'net_image.dart';

/// بطاقة موحدة: صورة 16:9 والعنوان تحتها (للأقسام والفيديوهات والحلقات).
class MediaCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;
  final BoxFit fit;
  final IconData? placeholderIcon;
  final bool selected;
  final bool showPlay;
  final String? badge;

  const MediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
    this.fit = BoxFit.cover,
    this.placeholderIcon,
    this.selected = false,
    this.showPlay = false,
    this.badge,
  });

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cw = c.maxWidth;
      final fs = cardFontSize(cw);
      final radius = BorderRadius.circular(cw < 200 ? 8 : 12);
      final contain = widget.fit == BoxFit.contain;

      final Widget image;
      if (widget.imageUrl.trim().isEmpty && widget.placeholderIcon != null) {
        image = DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF2A0A0C), Color(0xFF111111)],
            ),
          ),
          child: Center(
            child: Icon(widget.placeholderIcon,
                color: const Color(0x66FFFFFF), size: cw * 0.22),
          ),
        );
      } else {
        image = Container(
          color: contain ? AppColors.surface : AppColors.black,
          padding: EdgeInsets.all(contain ? cw * 0.06 : 0),
          child: NetImage(url: widget.imageUrl, fit: widget.fit),
        );
      }

      final highlight = widget.selected || _hover;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _hover ? 1.03 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: radius,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        image,
                        if (widget.showPlay)
                          const Center(
                            child: Icon(Icons.play_circle_fill,
                                color: Color(0xCCFFFFFF), size: 34),
                          ),
                        if (widget.badge != null)
                          PositionedDirectional(
                            top: 6,
                            start: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle, color: Colors.white),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.badge!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (highlight)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: widget.selected
                                        ? AppColors.accentRed
                                        : AppColors.accentRed2,
                                    width: widget.selected ? 3 : 2,
                                  ),
                                  borderRadius: radius,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: cardTextHeight(cw),
                child: Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: widget.selected ? AppColors.accentRed2 : AppColors.text,
                    fontSize: fs,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
