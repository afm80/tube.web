import 'dart:convert';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

/// يقرأ نفس بيانات الموقع من Firebase (categories + articles) دون أي تغيير في هيكلها.
class DataStore extends ChangeNotifier {
  bool loading = true;
  bool failed = false;
  List<Category> categories = [];
  List<Article> articles = []; // الأحدث أولًا

  Future<void> load() async {
    loading = true;
    failed = false;
    notifyListeners();
    try {
      final results = await Future.wait([_get('categories'), _get('articles')]);
      categories = _parseCategories(results[0]);
      final list = _parseArticles(results[1]);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      articles = list;
    } catch (_) {
      failed = true;
    }
    loading = false;
    notifyListeners();
  }

  Future<dynamic> _get(String path) async {
    final res = await http
        .get(Uri.parse('${AppConfig.firebaseUrl}/$path.json'))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  List<MapEntry<String, Map<String, dynamic>>> _entries(dynamic data) {
    final out = <MapEntry<String, Map<String, dynamic>>>[];
    if (data is Map) {
      data.forEach((k, v) {
        if (v is Map) out.add(MapEntry(k.toString(), Map<String, dynamic>.from(v)));
      });
    } else if (data is List) {
      for (var i = 0; i < data.length; i++) {
        final v = data[i];
        if (v is Map) out.add(MapEntry('$i', Map<String, dynamic>.from(v)));
      }
    }
    return out;
  }

  List<Category> _parseCategories(dynamic data) {
    final entries = _entries(data);
    final out = <Category>[];
    for (var i = 0; i < entries.length; i++) {
      out.add(Category.fromJson(entries[i].key, entries[i].value, i));
    }
    return out;
  }

  List<Article> _parseArticles(dynamic data) =>
      _entries(data).map((e) => Article.fromJson(e.key, e.value)).toList();

  // ---------- مساعدات الأقسام ----------

  Category? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Article? articleById(String id) {
    for (final a in articles) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// الأقسام الرئيسية: بلا أب، أو أبوها غير موجود.
  List<Category> get roots {
    final ids = categories.map((c) => c.id).toSet();
    return categories
        .where((c) => c.parentId == null || !ids.contains(c.parentId))
        .toList();
  }

  List<Category> childrenOf(String id) {
    final list = categories.where((c) => c.parentId == id).toList();
    list.sort((a, b) {
      if (a.createdAt != 0 && b.createdAt != 0 && a.createdAt != b.createdAt) {
        return a.createdAt.compareTo(b.createdAt);
      }
      return a.order.compareTo(b.order);
    });
    return list;
  }

  /// آباء القسم من الأعلى إلى الأقرب (للمسار أعلى الصفحة).
  List<Category> ancestorsOf(String id) {
    final out = <Category>[];
    final seen = <String>{id};
    var current = categoryById(id);
    while (current != null && current.parentId != null) {
      final parent = categoryById(current.parentId!);
      if (parent == null || !seen.add(parent.id)) break;
      out.insert(0, parent);
      current = parent;
    }
    return out;
  }

  /// القسم وكل أقسامه الفرعية.
  Set<String> categoryFilter(String id) {
    final ids = <String>{id};
    final queue = <String>[id];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      for (final c in categories) {
        if (c.parentId == current && ids.add(c.id)) queue.add(c.id);
      }
    }
    return ids;
  }

  /// ترتيب الصفحة الرئيسية: مثبّت الفيديو ثم المثبّت ثم الأحدث.
  List<Article> get homeSorted {
    final list = List<Article>.from(articles);
    list.sort((a, b) {
      if (a.videoPinned != b.videoPinned) return a.videoPinned ? -1 : 1;
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }
}

final DataStore store = DataStore();
