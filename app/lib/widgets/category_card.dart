import 'package:flutter/material.dart';

import '../config.dart';
import '../models.dart';
import '../utils.dart';
import 'net_image.dart';

/// بطاقة قسم بنسبة 16:9 بصورة القسم من لوحة التحكم، تتكيّف مع عرضها.
class CategoryCard extends StatelessWidget {
  final Category category;
  final double radius;

  const CategoryCard({super.key, required this.category, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    final hasImage = category.iconUrl.isNotEmpty;
    return LayoutBuilder(builder: (context, c) {
      final fs = cardFontSize(c.maxWidth) + 1;
      final pad = c.maxWidth < 200 ? 8.0 : 12.0;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => openCategory(context, category),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  NetImage(url: category.iconUrl)
                else
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF2A0A0C), Color(0xFF111111)],
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(pad, 26, pad, pad),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x66000000),
                          Color(0xE6000000),
                        ],
                        stops: [0, 0.4, 1],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                            width: 4, height: fs + 4, color: AppColors.accentRed2),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fs,
                              fontWeight: FontWeight.w800,
                              height: 1.35,
                              shadows: const [
                                Shadow(
                                    color: Color(0xCC000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
