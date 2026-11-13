import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config.dart';
import 'data_service.dart';
import 'screens/article_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  store.load();
  runApp(const AlfahamApp());
}

/// يسمح بالسحب بالماوس (للويب) مثل سحب البطاقات في الموقع.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}

class AlfahamApp extends StatelessWidget {
  const AlfahamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        surface: AppColors.surface,
      ),
    );
    return MaterialApp(
      title: 'Alfaham Tube',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(textTheme: GoogleFonts.cairoTextTheme(base.textTheme)),
      scrollBehavior: AppScrollBehavior(),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: '/',
      onGenerateRoute: _route,
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}

Route<dynamic> _route(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '/');
  final seg = uri.pathSegments;
  final Widget page;
  if (seg.length == 2 && seg[0] == 'category') {
    page = BrowseScreen(categoryId: seg[1]);
  } else if (seg.length == 2 && seg[0] == 'article') {
    page = ArticleScreen(articleId: seg[1]);
  } else if (seg.isNotEmpty && seg[0] == 'search') {
    page = BrowseScreen(
      categoryId: uri.queryParameters['category'],
      query: uri.queryParameters['q'],
    );
  } else {
    page = const HomeScreen();
  }
  return MaterialPageRoute(settings: settings, builder: (_) => page);
}
