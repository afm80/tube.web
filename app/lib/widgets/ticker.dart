import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../config.dart';
import '../models.dart';
import '../utils.dart';

/// شريط آخر المواضيع (أحمر) يتحرك باستمرار مثل الموقع.
class LatestTicker extends StatefulWidget {
  final List<Article> articles;

  const LatestTicker({super.key, required this.articles});

  @override
  State<LatestTicker> createState() => _LatestTickerState();
}

class _LatestTickerState extends State<LatestTicker>
    with SingleTickerProviderStateMixin {
  final ScrollController _sc = ScrollController();
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1000000.0;
    _last = elapsed;
    if (widget.articles.isEmpty || !_sc.hasClients) return;
    _sc.jumpTo(_sc.offset + 45 * dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.articles;
    return Container(
      height: 30,
      width: double.infinity,
      color: AppColors.red,
      child: items.isEmpty
          ? const Center(
              child: Text(
                'لا توجد مواضيع منشورة حاليًا',
                style: TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            )
          : ListView.builder(
              controller: _sc,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final a = items[index % items.length];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => openArticle(context, a),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('•',
                              style: TextStyle(color: AppColors.orange, fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(
                            a.title.isEmpty ? 'موضوع جديد' : a.title,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
