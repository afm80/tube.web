import 'package:flutter/material.dart';

import '../models.dart';
import '../utils.dart';
import 'media_card.dart';

/// بطاقة فيديو: الصورة 16:9 والعنوان تحتها.
class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      imageUrl: articleImage(article),
      title: article.title.isEmpty ? 'عنوان غير متاح' : article.title,
      onTap: () => openArticle(context, article),
    );
  }
}
