String _str(dynamic v) => v == null ? '' : v.toString().trim();

String _firstNonEmpty(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = _str(m[k]);
    if (v.isNotEmpty) return v;
  }
  return '';
}

int _int(dynamic v) {
  if (v is num) return v.toInt();
  return int.tryParse(_str(v)) ?? 0;
}

bool _truthy(dynamic v) => v == true || v == 'true' || v == 1;

/// يفك ترميز HTML في العناوين القادمة من يوتيوب (مثل &quot; و &#39; و &amp;).
String decodeEntities(String input) {
  if (!input.contains('&')) return input;
  var out = input.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
    final code = int.tryParse(m[1]!);
    return code == null ? m[0]! : String.fromCharCode(code);
  });
  out = out.replaceAllMapped(RegExp(r'&#[xX]([0-9a-fA-F]+);'), (m) {
    final code = int.tryParse(m[1]!, radix: 16);
    return code == null ? m[0]! : String.fromCharCode(code);
  });
  return out
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&');
}


class Category {
  final String id;
  final String name;
  final String sectionTitle;
  final String url;
  final String iconUrl;
  final String? parentId;
  final int createdAt;
  final int order;

  const Category({
    required this.id,
    required this.name,
    required this.sectionTitle,
    required this.url,
    required this.iconUrl,
    required this.parentId,
    required this.createdAt,
    required this.order,
  });

  factory Category.fromJson(String id, Map<String, dynamic> v, int order) {
    final name = _firstNonEmpty(v, ['name', 'nam', 'title', 'label']);
    final parent = _str(v['parentId']);
    return Category(
      id: id,
      name: name.isEmpty ? 'قسم' : decodeEntities(name),
      sectionTitle: decodeEntities(
          _firstNonEmpty(v, ['sectionTitle', 'columnTitle', 'titleLabel', 'name'])),
      url: _str(v['url']),
      iconUrl: _firstNonEmpty(
          v, ['iconUrl', 'imageUrl', 'logoUrl', 'icon', 'image', 'categoryImage']),
      parentId: parent.isEmpty ? null : parent,
      createdAt: _int(v['createdAt']),
      order: order,
    );
  }
}

class Article {
  final String id;
  final String title;
  final String categoryId;
  final String imageUrl;
  final String url;
  final String content;
  final String extraImages;
  final List<String> videoUrls;
  final int createdAt;
  final bool pinned;
  final bool videoPinned;

  const Article({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.imageUrl,
    required this.url,
    required this.content,
    required this.extraImages,
    required this.videoUrls,
    required this.createdAt,
    required this.pinned,
    required this.videoPinned,
  });

  factory Article.fromJson(String id, Map<String, dynamic> v) {
    final urls = <String>[];
    final raw = v['videoUrls'];
    if (raw is List) {
      for (final x in raw) {
        final s = _str(x);
        if (s.isNotEmpty) urls.add(s);
      }
    } else if (raw is Map) {
      for (final x in raw.values) {
        final s = _str(x);
        if (s.isNotEmpty) urls.add(s);
      }
    }
    final single = _str(v['videoUrl']);
    final List<String> list =
        urls.isNotEmpty ? urls : (single.isNotEmpty ? [single] : <String>[]);
    return Article(
      id: id,
      title: decodeEntities(_str(v['title'])),
      categoryId: _str(v['categoryId']),
      imageUrl: _str(v['imageUrl']),
      url: _firstNonEmpty(v, ['url', 'link']),
      content: (v['content'] ?? '').toString(),
      extraImages: _str(v['extraImages']),
      videoUrls: list,
      createdAt: _int(v['createdAt']),
      pinned: _truthy(v['pinned']),
      videoPinned: _truthy(v['videoPinned']),
    );
  }
}
