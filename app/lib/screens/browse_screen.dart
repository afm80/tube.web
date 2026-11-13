import 'package:flutter/material.dart';

import '../config.dart';
import '../data_service.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/article_card.dart';
import '../widgets/category_card.dart';
import '../widgets/pagination.dart';
import '../widgets/shell.dart';

/// صفحة قسم، أو نتائج بحث (نفس منطق index.html?category=&q=).
class BrowseScreen extends StatefulWidget {
  final String? categoryId;
  final String? query;

  const BrowseScreen({super.key, this.categoryId, this.query});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    return Shell(
      categoryId: widget.categoryId,
      activeId: widget.categoryId ?? 'none',
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
            child: _content(),
          );
        },
      ),
    );
  }

  Widget _content() {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final hp = sidePadding(w, w < 400 ? 10 : (w <= 768 ? 12 : 20));
      final cols = gridColumns(w);
      final gap = gridGap(w);
      final extent = cardExtent(cellWidth(w, hp, cols, gap));

      final q = (widget.query ?? '').trim().toLowerCase();
      final list = store.articles.where((a) {
        final text = '${a.title} ${a.content}'.toLowerCase();
        final matchCat = widget.categoryId == null || a.categoryId == widget.categoryId;
        final matchSearch = q.isEmpty || text.contains(q);
        return matchCat && matchSearch;
      }).toList();

      final children = widget.categoryId == null
          ? <Category>[]
          : store.childrenOf(widget.categoryId!);

      final totalPages =
          list.isEmpty ? 1 : (list.length / AppConfig.articlesPerPage).ceil();
      final page = _page.clamp(1, totalPages);
      final start = (page - 1) * AppConfig.articlesPerPage;
      final pageItems = list.skip(start).take(AppConfig.articlesPerPage).toList();

      SliverGridDelegate delegate() => SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            mainAxisExtent: extent,
          );

      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (children.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 16, hp, 8),
              sliver: SliverGrid(
                gridDelegate: delegate(),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => CategoryCard(category: children[i]),
                  childCount: children.length,
                ),
              ),
            ),
          if (list.isEmpty && children.isEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 20, hp, 20),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      widget.categoryId == null
                          ? 'لا توجد فيديوهات منشورة حاليًا.'
                          : 'لا توجد فيديوهات في هذا القسم حاليًا.',
                      style: const TextStyle(
                          color: Color(0xFFD4D4D4), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          if (list.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 14, hp, 10),
              sliver: SliverGrid(
                gridDelegate: delegate(),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => ArticleCard(article: pageItems[i]),
                  childCount: pageItems.length,
                ),
              ),
            ),
          if (totalPages > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                child: Pagination(
                  total: totalPages,
                  page: page,
                  onPage: (p) => setState(() => _page = p),
                ),
              ),
            ),
        ],
      );
    });
  }
}
