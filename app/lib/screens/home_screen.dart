import 'package:flutter/material.dart';

import '../config.dart';
import '../data_service.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/article_card.dart';
import '../widgets/featured_reel.dart';
import '../widgets/shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Shell(
      activeId: 'home',
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          if (store.loading && store.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.red));
          }
          if (store.failed && store.articles.isEmpty) {
            return RetryView(onRetry: store.load);
          }
          return RefreshIndicator(
            color: AppColors.red,
            onRefresh: store.load,
            child: const _HomeBody(),
          );
        },
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final hp = sidePadding(w, w <= 768 ? 12 : 20);
      final sorted = store.homeSorted;
      final roots = [...store.roots]..sort((a, b) => a.name.compareTo(b.name));

      final sections = <Widget>[];
      for (final cat in roots) {
        final ids = store.categoryFilter(cat.id);
        final list = sorted.where((a) => ids.contains(a.categoryId)).take(10).toList();
        if (list.isEmpty) continue;
        sections.add(_HomeSection(category: cat, articles: list, screenWidth: w));
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hp, 14, hp, 24),
        children: [
          FeaturedReel(articles: store.articles),
          if (sections.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('لا توجد فيديوهات منشورة حاليًا.',
                    style: TextStyle(
                        color: Color(0xFFD4D4D4), fontWeight: FontWeight.w700)),
              ),
            )
          else
            ...sections,
        ],
      );
    });
  }
}

class _HomeSection extends StatelessWidget {
  final Category category;
  final List<Article> articles;
  final double screenWidth;

  const _HomeSection({
    required this.category,
    required this.articles,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    double cw;
    double ch;
    double fs;
    if (screenWidth > 768) {
      cw = 280;
      ch = 200;
      fs = 14;
    } else if (screenWidth > 480) {
      cw = 220;
      ch = 170;
      fs = 14;
    } else {
      cw = 190;
      ch = 155;
      fs = 13;
    }
    final title =
        (category.sectionTitle.isEmpty ? category.name : category.sectionTitle).trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(screenWidth <= 480 ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? 'قسم' : title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: screenWidth <= 768 ? 16 : 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => openCategory(context, category),
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                        color: AppColors.accentRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: ch,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: articles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) => ArticleCard(
                article: articles[i],
                width: cw,
                height: ch,
                radius: 12,
                fontSize: fs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
