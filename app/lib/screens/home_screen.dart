import 'package:flutter/material.dart';

import '../config.dart';
import '../data_service.dart';
import '../utils.dart';
import '../widgets/category_card.dart';
import '../widgets/shell.dart';

/// الرئيسية: بطاقات الأقسام الرئيسية فقط (شبكة).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Shell(
      activeId: 'home',
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          if (store.loading && store.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.red));
          }
          if (store.failed && store.categories.isEmpty) {
            return RetryView(onRetry: store.load);
          }
          return RefreshIndicator(
            color: AppColors.red,
            onRefresh: store.load,
            child: const _HomeBody(),
          );
        },
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final hp = sidePadding(w, w < 400 ? 10 : (w <= 768 ? 12 : 20));
      final gap = gridGap(w);
      final roots = [...store.roots]..sort((a, b) => a.name.compareTo(b.name));

      if (roots.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hp, 20, hp, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('لا توجد أقسام حاليًا.',
                    style: TextStyle(
                        color: Color(0xFFD4D4D4), fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      }

      return GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hp, 14, hp, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns(w),
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          mainAxisExtent: cardExtent(cellWidth(w, hp, gridColumns(w), gap)),
        ),
        itemCount: roots.length,
        itemBuilder: (context, i) => CategoryCard(category: roots[i]),
      );
    });
  }
}
