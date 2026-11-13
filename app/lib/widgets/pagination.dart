import 'package:flutter/material.dart';

import '../config.dart';

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

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var p = 1; p <= total; p++)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onPage(p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: p == page ? AppColors.red : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: p == page ? AppColors.red : const Color(0x1FFFFFFF)),
                ),
                child: Text(
                  '$p',
                  style: TextStyle(
                    color: p == page ? Colors.white : const Color(0xFFEEEEEE),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
