import 'package:flutter/material.dart';

import '../utils.dart';

/// هيكل رمادي متحرك يظهر أثناء تحميل البيانات بدل الشاشة الفارغة.
class SkeletonGrid extends StatefulWidget {
  const SkeletonGrid({super.key});

  @override
  State<SkeletonGrid> createState() => _SkeletonGridState();
}

class _SkeletonGridState extends State<SkeletonGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final hp = pageSidePad(w);
      final gap = gridGap(w);
      final cols = gridColumns(w);
      final cw = cellWidth(w, hp, cols, gap);
      const base = Color(0xFF1E1E1E);
      return FadeTransition(
        opacity: Tween<double>(begin: 0.35, end: 0.85)
            .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hp, 14, hp, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            mainAxisExtent: cardExtent(cw),
          ),
          itemCount: cols * 4,
          itemBuilder: (context, i) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: cw * 0.7,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
