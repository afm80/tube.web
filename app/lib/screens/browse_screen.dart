import 'package:flutter/material.dart';

import '../config.dart';
import '../data_service.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/article_card.dart';
import '../widgets/category_card.dart';
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

      final totalPages = list.isEmpty
          ? 1
          : (list.length / AppConfig.articlesPerPage).ceil();
      final page = _page.clamp(1, totalPages);
      final start = (page - 1) * AppConfig.articlesPerPage;
      final pageItems = list.skip(start).take(AppConfig.articlesPerPage).toList();

      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (children.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 16, hp, 4),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: gap,
                  crossAxisSpacing: gap,
                  childAspectRatio: 16 / 9,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => CategoryCard(category: children[i]),
                  childCount: children.length,
                ),
              ),
            ),
          if (list.isEmpty)
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
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 18, hp, 10),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: gap,
                  crossAxisSpacing: gap,
                  childAspectRatio: 16 / 9,
                ),
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
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var p = 1; p <= totalPages; p++)
                      _PageButton(
                        number: p,
                        active: p == page,
                        onTap: () => setState(() => _page = p),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _PageButton extends StatelessWidget {
  final int number;
  final bool active;
  final VoidCallback onTap;

  const _PageButton({required this.number, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.red : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.red : const Color(0x1FFFFFFF)),
          ),
          child: Text('$number',
              style: TextStyle(
                  color: active ? Colors.white : const Color(0xFFEEEEEE),
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ),
      ),
    );
  }
}
