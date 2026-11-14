import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../config.dart';
import '../data_service.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/article_card.dart';
import '../widgets/media_card.dart';
import '../widgets/pagination.dart';
import '../widgets/shell.dart';
import '../widgets/skeleton.dart';
import '../widgets/video_views.dart';

class ArticleScreen extends StatelessWidget {
  final String articleId;

  const ArticleScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Shell(
      activeId: 'none',
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          if (store.loading && store.articles.isEmpty) {
            return const SkeletonGrid();
          }
          final a = store.articleById(articleId);
          if (a == null) {
            return Center(
              child: Text(
                store.failed ? 'حدث خطأ أثناء تحميل الموضوع.' : 'الموضوع غير موجود.',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
              ),
            );
          }
          return _ArticleView(article: a);
        },
      ),
    );
  }
}

class _ArticleView extends StatefulWidget {
  final Article article;

  const _ArticleView({required this.article});

  @override
  State<_ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<_ArticleView> {
  bool _shareOpen = false;
  String _status = '';
  int _ep = 0; // الحلقة المحددة
  bool _epTapped = false; // بعد الضغط على حلقة يعمل الصوت
  int _epPage = 1;
  final ScrollController _sc = ScrollController();

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  String get _link {
    final a = widget.article;
    if (AppConfig.siteUrl.isNotEmpty) {
      return '${AppConfig.siteUrl}/#/article/${Uri.encodeComponent(a.id)}';
    }
    return a.videoUrls.isNotEmpty ? a.videoUrls.first : '';
  }

  Future<void> _copy() async {
    final a = widget.article;
    final text = _link.isEmpty ? a.title : _link;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) setState(() => _status = 'تم نسخ الرابط');
  }

  int _colsFor(double width) => ((width + 10) / 150).floor().clamp(2, 4);

  void _scrollTop() {
    if (_sc.hasClients) {
      _sc.animateTo(0,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final title = a.title.isEmpty ? 'عنوان غير متاح' : a.title;
    final content = a.content.trim().isEmpty ? 'لا توجد تفاصيل لهذا المقال.' : a.content;

    final contentText = stripHtml(content);
    final normTitle = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    final placeholders = {'لا توجد تفاصيل لهذا المقال.', 'Alfaham Tube', normTitle};
    final hasText = contentText.isNotEmpty && !placeholders.contains(contentText);
    final hasCustomImage = a.imageUrl.isNotEmpty;
    final hasContentImage = RegExp(r'<img\b', caseSensitive: false).hasMatch(content);
    final hasVideo = a.videoUrls.isNotEmpty;
    final hasDetails = hasText || hasCustomImage || hasContentImage;
    final videoOnly = hasVideo && !hasDetails;

    final html = content.contains('<') ? content : content.replaceAll('\n', '<br>');
    final extra = a.extraImages
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final narrow = w <= 768;
      final outerW = narrow ? w - 20 : 820.0; // عرض الصندوق
      final innerW = narrow ? w - 44 : 760.0; // عرض المحتوى داخل الصندوق
      final epCols = _colsFor(innerW);
      final epPerPage = epCols * AppConfig.rowsPerPage;
      final total = a.videoUrls.length;

      final similarCols = _colsFor(outerW);
      final similar = a.categoryId.isEmpty
          ? <Article>[]
          : store.articles
              .where((x) => x.id != a.id && x.categoryId == a.categoryId)
              .take(similarCols == 4 ? 8 : 6)
              .toList();

      return ListView(
        controller: _sc,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            narrow ? 10 : (w - 820) / 2, 14, narrow ? 10 : (w - 820) / 2, 28),
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: narrow ? 12 : 30, vertical: narrow ? 16 : 30),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(narrow ? 10 : 14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: narrow ? 22 : 30,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                if (hasCustomImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(narrow ? 8 : 12),
                    child: Image.network(
                      a.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (total == 1) ...[
                  _video(a.videoUrls[0], autoPlay: true, mute: true, keyId: '0'),
                  const SizedBox(height: 20),
                ] else if (total > 1) ...[
                  _video(a.videoUrls[_ep],
                      autoPlay: true, mute: !_epTapped, keyId: '$_ep'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'الحلقة ${_ep + 1} من $total',
                          style: const TextStyle(
                              color: AppColors.accentRed2,
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (_ep < total - 1)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _ep = _ep + 1;
                              _epTapped = true;
                              _epPage = (_ep ~/ epPerPage) + 1;
                            });
                            _scrollTop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('الحلقة التالية ‹',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _episodes(a, innerW, epCols, epPerPage),
                  const SizedBox(height: 20),
                ],
                if (!videoOnly) ...[
                  HtmlWidget(
                    html,
                    textStyle: TextStyle(
                      color: const Color(0xFFF0F0F0),
                      fontSize: narrow ? 16 : 18,
                      height: 1.8,
                    ),
                    customStylesBuilder: (element) {
                      if (element.localName == 'a') {
                        return {'color': '#ffb347', 'text-decoration': 'underline'};
                      }
                      return null;
                    },
                    onTapUrl: (url) async {
                      await openExternal(url);
                      return true;
                    },
                  ),
                  const SizedBox(height: 25),
                ],
                _shareBlock(title),
                for (final img in extra) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      img,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (similar.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Row(
              children: [
                SizedBox(
                  width: 4,
                  height: 20,
                  child: ColoredBox(color: AppColors.accentRed2),
                ),
                SizedBox(width: 8),
                Text(
                  'فيديوهات مشابهة',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _cardsGrid(
              width: outerW,
              cols: similarCols,
              itemCount: similar.length,
              builder: (i) => ArticleCard(article: similar[i]),
            ),
          ],
        ],
      );
    });
  }

  Widget _cardsGrid({
    required double width,
    required int cols,
    required int itemCount,
    required Widget Function(int) builder,
  }) {
    const gap = 10.0;
    final cw = (width - gap * (cols - 1)) / cols;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        mainAxisExtent: cardExtent(cw),
      ),
      itemCount: itemCount,
      itemBuilder: (context, i) => builder(i),
    );
  }

  Widget _video(String url,
      {required bool autoPlay, required bool mute, required String keyId}) {
    final id = youtubeId(url);
    final Widget player = id != null
        ? YoutubeView(
            key: ValueKey('yt-$keyId-$id'), videoId: id, autoPlay: autoPlay, mute: mute)
        : DirectVideoView(
            key: ValueKey('dv-$keyId-$url'), url: url, autoPlay: autoPlay, mute: mute);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(color: Colors.black, child: player),
    );
  }

  /// الحلقات كبطاقات شبكية (الصورة المصغّرة والعنوان تحتها). الضغط يشغّل الحلقة.
  Widget _episodes(Article a, double width, int cols, int perPage) {
    final total = a.videoUrls.length;
    final pages = (total / perPage).ceil();
    final page = _epPage.clamp(1, pages);
    final start = (page - 1) * perPage;
    final end = start + perPage > total ? total : start + perPage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحلقات ($total)',
          style: const TextStyle(
              color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _cardsGrid(
          width: width,
          cols: cols,
          itemCount: end - start,
          builder: (i) {
            final idx = start + i;
            final id = youtubeId(a.videoUrls[idx]);
            return MediaCard(
              imageUrl: id != null ? 'https://img.youtube.com/vi/$id/hqdefault.jpg' : '',
              title: 'الحلقة ${idx + 1}',
              placeholderIcon: Icons.play_circle_outline,
              showPlay: true,
              selected: idx == _ep,
              onTap: () {
                setState(() {
                  _ep = idx;
                  _epTapped = true;
                });
                _scrollTop();
              },
            );
          },
        ),
        if (pages > 1) ...[
          const SizedBox(height: 14),
          Pagination(
            total: pages,
            page: page,
            onPage: (p) => setState(() => _epPage = p),
          ),
        ],
      ],
    );
  }

  Widget _shareBlock(String title) {
    final link = _link;
    final text = link.isEmpty ? title : '$title $link';
    final enc = Uri.encodeComponent;

    Widget circle(Widget child, Color bg, VoidCallback onTap, String tip) {
      return Tooltip(
        message: tip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('مشاركة الموضوع:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          circle(const Icon(Icons.share, size: 20, color: Color(0xFF111111)),
              AppColors.orange, () => setState(() => _shareOpen = !_shareOpen),
              'إظهار خيارات المشاركة'),
          if (_shareOpen) ...[
            circle(const Icon(Icons.chat, size: 20, color: Colors.white),
                const Color(0xFF20A85A),
                () => openExternal('https://wa.me/?text=${enc(text)}'),
                'واتساب'),
            circle(const Icon(Icons.facebook, size: 22, color: Colors.white),
                const Color(0xFF1877F2),
                () => openExternal(
                    'https://www.facebook.com/sharer/sharer.php?u=${enc(link)}'),
                'فيسبوك'),
            circle(const Icon(Icons.send, size: 19, color: Colors.white),
                const Color(0xFF229ED9),
                () => openExternal(
                    'https://t.me/share/url?url=${enc(link)}&text=${enc(title)}'),
                'تيليجرام'),
            circle(
                const Text('X',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                const Color(0xFF111111),
                () => openExternal(
                    'https://twitter.com/intent/tweet?url=${enc(link)}&text=${enc(title)}'),
                'X'),
            circle(const Icon(Icons.link, size: 21, color: Color(0xFF111111)),
                AppColors.orange, _copy, 'نسخ الرابط'),
          ],
          if (_status.isNotEmpty)
            Text(_status,
                style: const TextStyle(
                    color: Color(0xFF8FE99D), fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
