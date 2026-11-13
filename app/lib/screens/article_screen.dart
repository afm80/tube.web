import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../config.dart';
import '../data_service.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/shell.dart';
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
            return const Center(child: CircularProgressIndicator(color: AppColors.red));
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

  String get _link {
    final a = widget.article;
    if (AppConfig.siteUrl.isNotEmpty) {
      return '${AppConfig.siteUrl}/article.html?id=${Uri.encodeComponent(a.id)}';
    }
    return a.videoUrls.isNotEmpty ? a.videoUrls.first : '';
  }

  Future<void> _copy() async {
    final a = widget.article;
    final text = _link.isEmpty ? a.title : _link;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) setState(() => _status = 'تم نسخ الرابط');
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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
            horizontal: narrow ? 12 : (w - 820) / 2, vertical: 14),
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: narrow ? 14 : 30, vertical: narrow ? 18 : 30),
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
                    fontSize: narrow ? 24 : 30,
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
                for (var i = 0; i < a.videoUrls.length; i++) ...[
                  _video(a.videoUrls[i], i == 0),
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
        ],
      );
    });
  }

  Widget _video(String url, bool first) {
    final id = youtubeId(url);
    final Widget player = id != null
        ? YoutubeView(key: ValueKey('yt-$id-$url'), videoId: id, autoPlay: first)
        : DirectVideoView(key: ValueKey('dv-$url'), url: url, autoPlay: first);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(color: Colors.black, child: player),
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
