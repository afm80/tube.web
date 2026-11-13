import 'package:flutter/material.dart';

import '../config.dart';
import '../models.dart';
import '../utils.dart';
import 'net_image.dart';

/// بطاقة فيديو بنسبة 16:9، يتكيّف خطها وهوامشها مع عرضها.
class ArticleCard extends StatelessWidget {
  final Article article;
  final double radius;

  const ArticleCard({super.key, required this.article, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    final title = article.title.isEmpty ? 'عنوان غير متاح' : article.title;
    return LayoutBuilder(builder: (context, c) {
      final fs = cardFontSize(c.maxWidth);
      final pad = c.maxWidth < 200 ? 8.0 : 12.0;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => openArticle(context, article),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.black),
                NetImage(url: articleImage(article)),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(pad, 24, pad, pad - 2),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x38000000),
                          Color(0xAD000000),
                          Color(0xEB000000),
                        ],
                        stops: [0, 0.28, 0.58, 1],
                      ),
                    ),
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fs,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        shadows: const [
                          Shadow(
                              color: Color(0xCC000000),
                              blurRadius: 8,
                              offset: Offset(0, 2)),
                        ],
                      ),
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
