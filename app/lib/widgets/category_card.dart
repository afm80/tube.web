import 'package:flutter/material.dart';

import '../models.dart';
import '../utils.dart';
import 'media_card.dart';

/// بطاقة قسم: صورة القسم 16:9 (تُعرض كاملة دون قص) والاسم تحتها.
class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      imageUrl: category.iconUrl,
      title: category.name,
      fit: BoxFit.contain,
      placeholderIcon: Icons.folder_open,
      onTap: () => openCategory(context, category),
    );
  }
}
