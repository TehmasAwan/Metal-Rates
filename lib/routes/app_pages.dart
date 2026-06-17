import 'package:get/get.dart';

// Routes abstract class is defined in app_routes.dart
import 'app_routes.dart';

// Views
import '../main.dart';
import '../views/converter/converter_screen.dart';
import '../views/graph/graph_screen.dart';
import '../views/home/home_screen.dart';
import '../views/jewellery/jewellery_screen.dart';
import '../views/settings/settings_screen.dart';
import '../views/splash/splash_screen.dart';
import '../views/zakat/zakat_screen.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = <GetPage>[
    // Splash screen route
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),

    // Root container hosting the bottom navigation tabs.
    GetPage(
      name: Routes.INITIAL,
      page: () => const MainContainer(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Feature routes
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.CONVERTER,
      page: () => const ConverterScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.ZAKAT,
      page: () => const ZakatScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.JEWELLERY,
      page: () => const JewelleryScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
      transition: Transition.fadeIn,
    ),

    // Graph page with slide transition
    GetPage(
      name: Routes.GRAPH,
      page: () {
        final String symbol = Get.arguments as String? ?? 'XAU';
        return GraphScreen(symbol: symbol);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 350),
    ),
  ];
}