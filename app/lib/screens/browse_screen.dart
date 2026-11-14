import 'package:flutter/material.dart';

import '../config.dart';
import '../data_service.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/article_card.dart';
import '../widgets/category_card.dart';
import '../widgets/pagination.dart';
import '../widgets/shell.dart';
import '../widgets/skeleton.dart';

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
  final ScrollController _sc = ScrollController();

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _goPage(int p) {
    setState(() => _page = p);
    if (_sc.hasClients) {
      _sc.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      categoryId: widget.categoryId,
      activeId: widget.categoryId ?? 'none',
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          if (store.loading && store.articles.isEmpty) {
            return const SkeletonGrid();
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
      final hp = pageSidePad(w);
      final cols = gridColumns(w);
      final gap = gridGap(w);
      final extent = cardExtent(cellWidth(w, hp, cols, gap));
      final perPage = cols * AppConfig.rowsPerPage;

      final rawQuery = (widget.query ?? '').trim();
      final q = rawQuery.toLowerCase();
      final list = store.articles.where((a) {
        final text = '${a.title} ${a.content}'.toLowerCase();
        final matchCat = widget.categoryId == null || a.categoryId == widget.categoryId;
        final matchSearch = q.isEmpty || text.contains(q);
        return matchCat && matchSearch;
      }).toList();

      final category =
          widget.categoryId == null ? null : store.categoryById(widget.categoryId!);
      final children = widget.categoryId == null
          ? <Category>[]
          : store.childrenOf(widget.categoryId!);

      final totalPages = list.isEmpty ? 1 : (list.length / perPage).ceil();
      final page = _page.clamp(1, totalPages);
      final start = (page - 1) * perPage;
      final pageItems = list.skip(start).take(perPage).toList();
      final both = children.isNotEmpty && list.isNotEmpty;

      SliverGridDelegate delegate() => SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            mainAxisExtent: extent,
          );

      return CustomScrollView(
        controller: _sc,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (rawQuery.isNotEmpty || category != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hp, 14, hp, 0),
                child: _PageHeader(
                  category: category,
                  query: rawQuery,
                  count: list.length,
                ),
              ),
            ),
          if (both)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hp, 16, hp, 0),
                child: const _SectionTitle('الأقسام'),
              ),
            ),
          if (children.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 12, hp, 8),
              sliver: SliverGrid(
                gridDelegate: delegate(),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => CategoryCard(category: children[i]),
                  childCount: children.length,
                ),
              ),
            ),
          if (both)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hp, 8, hp, 0),
                child: const _SectionTitle('الفيديوهات'),
              ),
            ),
          if (list.isEmpty && children.isEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 20, hp, 20),
              sliver: SliverToBoxAdapter(
                child: _EmptyState(
                  text: rawQuery.isNotEmpty
                      ? 'لا توجد نتائج للبحث عن «$rawQuery».'
                      : (widget.categoryId == null
                          ? 'لا توجد فيديوهات منشورة حاليًا.'
                          : 'لا توجد فيديوهات في هذا القسم حاليًا.'),
                  icon: rawQuery.isNotEmpty
                      ? Icons.search_off
                      : Icons.video_library_outlined,
                ),
              ),
            ),
          if (list.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 12, hp, 10),
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
                padding: EdgeInsets.fromLTRB(hp, 10, hp, 28),
                child: Pagination(
                  total: totalPages,
                  page: page,
                  onPage: _goPage,
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// عنوان الصفحة: المسار (للأقسام الفرعية) + اسم القسم أو عنوان البحث + العدد.
class _PageHeader extends StatelessWidget {
  final Category? category;
  final String query;
  final int count;

  const _PageHeader({
    required this.category,
    required this.query,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final ancestors =
        category == null ? <Category>[] : store.ancestorsOf(category!.id);
    final title = query.isNotEmpty
        ? 'نتائج البحث عن «$query»'
        : (category?.name ?? '');
    final countText = query.isNotEmpty ? '$count نتيجة' : '$count فيديو';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ancestors.isNotEmpty && query.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final a in ancestors) ...[
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => openCategory(context, a),
                      child: Text(
                        a.name,
                        style: const TextStyle(
                            color: Color(0xFFB5B5B5),
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const Text('‹',
                      style: TextStyle(color: Color(0xFF777777), fontSize: 15)),
                ],
                Text(
                  category!.name,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Container(width: 4, height: 22, color: AppColors.accentRed2),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x1FFFFFFF)),
                ),
                child: Text(
                  countText,
                  style: const TextStyle(
                      color: Color(0xFFD4D4D4),
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w800),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  final IconData icon;

  const _EmptyState({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: const Color(0xFF777777)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFFD4D4D4), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
