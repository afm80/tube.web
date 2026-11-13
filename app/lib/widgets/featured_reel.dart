import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../config.dart';
import '../data_service.dart';
import '../models.dart';
import '../utils.dart';
import 'net_image.dart';

/// سلايدر المميز: حتى 10 مواضيع (2 لكل قسم كحد أقصى) بترتيب عشوائي، يتحرك كل 5 ثوانٍ.
class FeaturedReel extends StatefulWidget {
  final List<Article> articles;

  const FeaturedReel({super.key, required this.articles});

  @override
  State<FeaturedReel> createState() => _FeaturedReelState();
}

class _FeaturedReelState extends State<FeaturedReel> {
  late List<Article> _deck;
  final PageController _pc = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _deck = _buildDeck();
    _restart();
  }

  @override
  void didUpdateWidget(covariant FeaturedReel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.articles, widget.articles)) {
      _deck = _buildDeck();
      _index = 0;
      if (_pc.hasClients) _pc.jumpToPage(0);
      _restart();
    }
  }

  List<Article> _buildDeck() {
    final rnd = Random();
    final all = widget.articles;
    final pool = store.categories.where((c) {
      final ids = store.categoryFilter(c.id);
      return all.any((a) => ids.contains(a.categoryId));
    }).toList()
      ..shuffle(rnd);

    final seen = <String>{};
    final deck = <Article>[];
    for (final c in pool) {
      final ids = store.categoryFilter(c.id);
      final items = all.where((a) => ids.contains(a.categoryId)).toList()
        ..shuffle(rnd);
      for (final a in items.take(2)) {
        if (seen.add(a.id)) deck.add(a);
      }
      if (deck.length >= 10) break;
    }
    if (deck.isEmpty) {
      deck.addAll(all.take(10));
    }
    deck.shuffle(rnd);
    return deck.take(10).toList();
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _go(_index + 1));
  }

  void _go(int target) {
    if (!mounted || _deck.length < 2 || !_pc.hasClients) return;
    final next = (target + _deck.length) % _deck.length;
    _pc.animateToPage(next,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_deck.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      final h = (constraints.maxWidth * 0.42).clamp(220.0, 430.0).toDouble();
      return Column(
        children: [
          SizedBox(
            height: h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PageView.builder(
                controller: _pc,
                itemCount: _deck.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final a = _deck[i];
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => openArticle(context, a),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: AppColors.black),
                          NetImage(url: articleImage(a)),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 40, 16, 14),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x14000000),
                                    Color(0x80000000),
                                    Color(0xD9000000),
                                  ],
                                  stops: [0, 0.3, 1],
                                ),
                              ),
                              child: Text(
                                a.title.isEmpty ? 'موضوع مميز' : a.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavButton(label: '‹', onTap: () {
                _go(_index - 1);
                _restart();
              }),
              const SizedBox(width: 10),
              for (var i = 0; i < _deck.length; i++)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index ? AppColors.accentRed : const Color(0x55FFFFFF),
                  ),
                ),
              const SizedBox(width: 10),
              _NavButton(label: '›', onTap: () {
                _go(_index + 1);
                _restart();
              }),
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Color(0x22FFFFFF)),
          child: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.1)),
        ),
      ),
    );
  }
}
