import 'package:flutter/material.dart';

import '../config.dart';
import '../models.dart';
import '../utils.dart';
import 'net_image.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final double? width;
  final double? height;
  final double radius;
  final double fontSize;

  const ArticleCard({
    super.key,
    required this.article,
    this.width,
    this.height,
    this.radius = 14,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final title = article.title.isEmpty ? 'عنوان غير متاح' : article.title;
    final card = ClipRRect(
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
              padding: const EdgeInsets.fromLTRB(12, 28, 12, 10),
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
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  shadows: const [
                    Shadow(color: Color(0xCC000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => openArticle(context, article),
        child: SizedBox(width: width, height: height, child: card),
      ),
    );
  }
}
