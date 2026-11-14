import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';
import 'data_service.dart';
import 'models.dart';

String? youtubeId(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  if (host == 'youtu.be') {
    return uri.pathSegments.isNotEmpty && uri.pathSegments.first.isNotEmpty
        ? uri.pathSegments.first
        : null;
  }
  if (!host.contains('youtube.com')) return null;
  if (uri.path == '/watch') {
    final v = uri.queryParameters['v'];
    return (v == null || v.isEmpty) ? null : v;
  }
  final seg = uri.pathSegments;
  if (seg.length >= 2 && (seg[0] == 'shorts' || seg[0] == 'live' || seg[0] == 'embed')) {
    return seg[1].isEmpty ? null : seg[1];
  }
  return null;
}

bool isHlsUrl(String url) =>
    RegExp(r'\.m3u8(?:$|[?#])', caseSensitive: false).hasMatch(url) ||
    RegExp(r'(?:format|type|protocol|stream)=?(?:hls|m3u8|application/x-mpegurl)',
            caseSensitive: false)
        .hasMatch(url) ||
    RegExp(r'(?:/|\b)(?:hls|playlist|manifest|live\.m3u8)(?:/|\b)',
            caseSensitive: false)
        .hasMatch(url);

bool isDashUrl(String url) =>
    RegExp(r'\.mpd(?:$|[?#])', caseSensitive: false).hasMatch(url) ||
    RegExp(r'(?:format|type|protocol|stream)=?(?:dash|mpd|application/dash\+xml)',
            caseSensitive: false)
        .hasMatch(url);

String articleImage(Article a) {
  if (a.imageUrl.isNotEmpty) return a.imageUrl;
  for (final u in a.videoUrls) {
    final id = youtubeId(u);
    if (id != null) return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }
  return AppConfig.fallbackImage;
}

String stripHtml(String html) => html
    .replaceAll(RegExp(r'<[^>]*>'), ' ')
    .replaceAll('&nbsp;', ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

Future<void> openExternal(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

// ---------- التنقل (نفس منطق الموقع: الرابط المخصص يفتح خارجيًا) ----------

void openArticle(BuildContext context, Article a) {
  if (a.url.isNotEmpty) {
    openExternal(a.url);
    return;
  }
  Navigator.of(context).pushNamed('/article/${Uri.encodeComponent(a.id)}');
}

void openCategory(BuildContext context, Category c) {
  if (c.url.isNotEmpty) {
    openExternal(c.url);
    return;
  }
  Navigator.of(context).pushNamed('/category/${Uri.encodeComponent(c.id)}');
}

void openHome(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
}

void openSearch(BuildContext context, {String? categoryId, String? query}) {
  final q = (query ?? '').trim();
  if (q.isEmpty && categoryId == null) {
    openHome(context);
    return;
  }
  if (q.isEmpty && categoryId != null) {
    Navigator.of(context).pushNamed('/category/${Uri.encodeComponent(categoryId)}');
    return;
  }
  final uri = Uri(path: '/search', queryParameters: {
    'q': q,
    if (categoryId != null) 'category': categoryId,
  });
  Navigator.of(context).pushNamed(uri.toString());
}

double sidePadding(double width, double base) {
  final extra = (width - AppConfig.maxContentWidth) / 2;
  return extra > 0 ? extra + base : base;
}

/// الهامش الجانبي للصفحة حسب العرض.
double pageSidePad(double width) =>
    sidePadding(width, width < 400 ? 10 : (width <= 768 ? 12 : 20));

/// عدد الأعمدة: أصغر عرض مريح للبطاقة نحو 140 بكسل (عمودان على الجوال، وأكثر كلما كبرت الشاشة).
int gridColumns(double width) {
  final usable = width - pageSidePad(width) * 2;
  final gap = gridGap(width);
  final c = ((usable + gap) / (140 + gap)).floor();
  return c.clamp(2, 6);
}

/// المسافة بين البطاقات: أصغر على الشاشات الصغيرة.
double gridGap(double width) => width < 400 ? 10 : (width < 700 ? 14 : 18);

/// حجم خط عنوان البطاقة حسب عرض البطاقة نفسها.
double cardFontSize(double cardWidth) =>
    (cardWidth * 0.058).clamp(11.5, 18.0).toDouble();

/// ارتفاع نص عنوان البطاقة (سطران) تحت الصورة.
double cardTextHeight(double cardWidth) => cardFontSize(cardWidth) * 1.35 * 2 + 2;

/// ارتفاع البطاقة الكاملة: صورة 16:9 + مسافة + العنوان تحتها.
double cardExtent(double cardWidth) =>
    cardWidth * 9 / 16 + 6 + cardTextHeight(cardWidth) + 1;

/// عرض البطاقة الواحدة في الشبكة.
double cellWidth(double totalWidth, double sidePad, int cols, double gap) =>
    (totalWidth - sidePad * 2 - gap * (cols - 1)) / cols;
