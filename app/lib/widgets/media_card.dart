import 'package:flutter/material.dart';

import '../config.dart';
import '../utils.dart';
import 'net_image.dart';

/// بطاقة موحدة: صورة 16:9 والعنوان تحتها (للأقسام والفيديوهات والحلقات).
class MediaCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;
  final BoxFit fit;
  final IconData? placeholderIcon;
  final bool selected;
  final bool showPlay;

  const MediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
    this.fit = BoxFit.cover,
    this.placeholderIcon,
    this.selected = false,
    this.showPlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cw = c.maxWidth;
      final fs = cardFontSize(cw);
      final radius = BorderRadius.circular(cw < 200 ? 8 : 12);
      final contain = fit == BoxFit.contain;

      final Widget image;
      if (imageUrl.trim().isEmpty && placeholderIcon != null) {
        image = DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF2A0A0C), Color(0xFF111111)],
            ),
          ),
          child: Center(
            child: Icon(placeholderIcon, color: const Color(0x66FFFFFF), size: cw * 0.22),
          ),
        );
      } else {
        image = Container(
          color: contain ? AppColors.surface : AppColors.black,
          padding: EdgeInsets.all(contain ? cw * 0.06 : 0),
          child: NetImage(url: imageUrl, fit: fit),
        );
      }

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      image,
                      if (showPlay)
                        const Center(
                          child: Icon(Icons.play_circle_fill,
                              color: Color(0xCCFFFFFF), size: 34),
                        ),
                      if (selected)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.accentRed, width: 3),
                                borderRadius: radius,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: cardTextHeight(cw),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: selected ? AppColors.accentRed2 : AppColors.text,
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
