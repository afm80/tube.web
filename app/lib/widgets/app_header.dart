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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => openHome(context),
              child: Image.asset(
                'assets/site-logo.png',
                width: _open ? 90 : 150,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (_open)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _submit(),
                        style: const TextStyle(color: Colors.black, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'ابحث',
                          hintStyle: const TextStyle(color: Colors.black45),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('بحث',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Spacer(),
          IconButton(
            tooltip: 'بحث',
            onPressed: () => setState(() => _open = !_open),
            icon: Icon(_open ? Icons.close : Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
