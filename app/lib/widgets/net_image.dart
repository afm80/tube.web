import 'package:flutter/material.dart';

import '../config.dart';

class NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const NetImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final src = url.trim().isEmpty ? AppConfig.fallbackImage : url.trim();
    return Image.network(
      src,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      errorBuilder: (context, error, stack) => Image.network(
        AppConfig.fallbackImage,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        errorBuilder: (context, error, stack) =>
            const ColoredBox(color: AppColors.surface),
      ),
    );
  }
}
