import 'package:flutter/material.dart';

class AppConfig {
  /// نفس قاعدة Firebase التي يستخدمها الموقع والبوت واللوحة.
  static const String firebaseUrl =
      'https://alfaham-tube-web-default-rtdb.firebaseio.com';

  /// رابط الموقع (بدون / في النهاية) لاستخدامه في المشاركة. مثال: https://example.com
  /// إذا تُرك فارغًا تُشارك الروابط من رابط الفيديو نفسه.
  static const String siteUrl = '';

  static const String fallbackImage =
      'https://raw.githubusercontent.com/h-80/img/refs/heads/main/Alfaham%20tube%201.png';

  static const int articlesPerPage = 12;
  static const double maxContentWidth = 1200;
}

class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color surface = Color(0xFF111111);
  static const Color text = Color(0xFFF5F5F5);
  static const Color red = Color(0xFFD71920);
  static const Color accentRed = Color(0xFFFF3B3B);
  static const Color accentRed2 = Color(0xFFFF4D4D);
  static const Color orange = Color(0xFFFF9900);
  static const Color link = Color(0xFFFFB347);
  static const Color border = Color(0x14FFFFFF);
}
