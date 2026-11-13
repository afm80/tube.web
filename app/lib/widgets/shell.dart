import 'package:flutter/material.dart';

import '../config.dart';
import '../data_service.dart';
import 'app_header.dart';
import 'categories_bar.dart';
import 'ticker.dart';

/// الإطار المشترك: الترويسة + شريط آخر المواضيع + المحتوى + شريط الأقسام السفلي.
class Shell extends StatelessWidget {
  final String? categoryId;
  final String? activeId;
  final Widget body;

  const Shell({super.key, this.categoryId, this.activeId, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(categoryId: categoryId),
            AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                if (store.loading && store.articles.isEmpty) {
                  return const SizedBox.shrink();
                }
                return LatestTicker(articles: store.articles.take(10).toList());
              },
            ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: CategoriesBar(activeId: activeId),
    );
  }
}

class RetryView extends StatelessWidget {
  final VoidCallback onRetry;

  const RetryView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('تعذر تحميل البيانات.',
              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red, foregroundColor: Colors.white),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
