import 'package:flutter/material.dart';

import '../config.dart';
import '../data_service.dart';
import '../models.dart';
import '../utils.dart';
import 'net_image.dart';

/// شريط الأقسام السفلي الثابت (الرئيسية + الأقسام الرئيسية).
class CategoriesBar extends StatelessWidget {
  final String? activeId;

  const CategoriesBar({super.key, this.activeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 92,
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final roots = store.roots;
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                children: [
                  _Item(
                    label: 'الرئيسية',
                    active: activeId == 'home',
                    icon: Image.asset('assets/home-icon.png',
                        width: 42, height: 42, fit: BoxFit.contain),
                    onTap: () => openHome(context),
                  ),
                  for (final c in roots) _categoryItem(context, c),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(BuildContext context, Category c) {
    final icon = SizedBox(
      width: 42,
      height: 42,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: NetImage(
          url: c.iconUrl.isEmpty ? AppConfig.fallbackImage : c.iconUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
    return _Item(
      label: c.name,
      active: activeId == c.id,
      icon: icon,
      onTap: () => openCategory(context, c),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final bool active;
  final Widget icon;
  final VoidCallback onTap;

  const _Item({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 84,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 26,
                height: 3,
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: active ? AppColors.accentRed2 : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? AppColors.accentRed2 : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: icon,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? AppColors.accentRed2 : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
