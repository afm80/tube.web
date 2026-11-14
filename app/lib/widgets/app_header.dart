import 'package:flutter/material.dart';

import '../config.dart';
import '../utils.dart';

class AppHeader extends StatefulWidget {
  /// عند وجوده يبقى البحث داخل هذا القسم (كما في الموقع).
  final String? categoryId;

  const AppHeader({super.key, this.categoryId});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _open = false;
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    openSearch(context, categoryId: widget.categoryId, query: _ctrl.text);
  }

  Widget _searchRow({required bool autofocus}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            autofocus: autofocus,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
            style: const TextStyle(color: Colors.black, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'ابحث',
              hintStyle: const TextStyle(color: Colors.black45),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 38,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: const Color(0xFF111111),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('بحث', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 700;
      final canBack = Navigator.of(context).canPop();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.black,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            if (canBack)
              IconButton(
                tooltip: 'رجوع',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => openHome(context),
                child: Image.asset(
                  'assets/site-logo.png',
                  width: (_open && !wide) ? 90 : 150,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (wide)
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SizedBox(width: 420, child: _searchRow(autofocus: false)),
                ),
              )
            else if (_open)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _searchRow(autofocus: true),
                ),
              )
            else
              const Spacer(),
            if (!wide)
              IconButton(
                tooltip: 'بحث',
                onPressed: () => setState(() => _open = !_open),
                icon: Icon(_open ? Icons.close : Icons.search, color: Colors.white),
              ),
          ],
        ),
      );
    });
  }
}
