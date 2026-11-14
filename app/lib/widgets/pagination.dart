import 'package:flutter/material.dart';

import '../config.dart';

/// ترقيم مختصر: مثلثان أحمران للخارج (السابق على اليمين والتالي على اليسار)
/// وبينهما أرقام تتكيّف مع عرض الشاشة وتبقى في صف واحد.
class Pagination extends StatelessWidget {
  final int total;
  final int page;
  final ValueChanged<int> onPage;

  const Pagination({
    super.key,
    required this.total,
    required this.page,
    required this.onPage,
  });

  static List<int?> _items(int total, int cur, int slots) {
    if (slots < 5) slots = 5;
    if (total <= slots) return [for (var i = 1; i <= total; i++) i];
    final sib = (slots - 5) ~/ 2;
    if (cur <= 3 + sib) {
      final end = slots - 2;
      return [for (var i = 1; i <= end; i++) i, null, total];
    }
    if (cur >= total - 2 - sib) {
      final startP = total - (slots - 2) + 1;
      return [1, null, for (var i = startP; i <= total; i++) i];
    }
    return [
      1,
      null,
      for (var i = cur - sib; i <= cur + sib; i++) i,
      null,
      total,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final narrow = c.maxWidth < 400;
      final btnW = narrow ? 30.0 : 38.0;
      final gap = narrow ? 4.0 : 6.0;
      final tri = narrow ? 36.0 : 44.0;
      final avail = c.maxWidth - tri * 2 - gap * 2;
      final slots = (avail / (btnW + gap)).floor().clamp(5, 11);
      final items = _items(total, page, slots);

      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Triangle(
                pointsRight: true,
                enabled: page > 1,
                size: tri,
                onTap: () => onPage(page - 1),
              ),
              SizedBox(width: gap),
              for (final it in items)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: gap / 2),
                  child: it == null
                      ? SizedBox(
                          width: btnW,
                          height: 36,
                          child: const Center(
                            child: Text('…',
                                style: TextStyle(
                                    color: Color(0xFF9A9A9A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ),
                        )
                      : _Num(
                          number: it,
                          active: it == page,
                          width: btnW,
                          onTap: () => onPage(it),
                        ),
                ),
              SizedBox(width: gap),
              _Triangle(
                pointsRight: false,
                enabled: page < total,
                size: tri,
                onTap: () => onPage(page + 1),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Num extends StatelessWidget {
  final int number;
  final bool active;
  final double width;
  final VoidCallback onTap;

  const _Num({
    required this.number,
    required this.active,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.red : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: active ? AppColors.red : const Color(0x1FFFFFFF)),
          ),
          child: Text(
            '$number',
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFFEEEEEE),
              fontWeight: FontWeight.w700,
              fontSize: width < 34 ? 13 : 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _Triangle extends StatelessWidget {
  final bool pointsRight;
  final bool enabled;
  final double size;
  final VoidCallback onTap;

  const _Triangle({
    required this.pointsRight,
    required this.enabled,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _TriPainter(
              pointsRight: pointsRight,
              color: enabled ? AppColors.red : const Color(0xFF3A3A3A),
            ),
          ),
        ),
      ),
    );
  }
}

class _TriPainter extends CustomPainter {
  final bool pointsRight;
  final Color color;

  const _TriPainter({required this.pointsRight, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final inset = w * 0.24;
    final path = Path();
    if (pointsRight) {
      path
        ..moveTo(inset, inset)
        ..lineTo(inset, h - inset)
        ..lineTo(w - inset, h / 2)
        ..close();
    } else {
      path
        ..moveTo(w - inset, inset)
        ..lineTo(w - inset, h - inset)
        ..lineTo(inset, h / 2)
        ..close();
    }
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _TriPainter old) =>
      old.pointsRight != pointsRight || old.color != color;
}
