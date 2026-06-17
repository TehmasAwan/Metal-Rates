import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Root utilities
import 'screen_utils.dart';

// Core Constants
import 'core/constants/colors.dart';
import 'core/constants/strings.dart';

// Data services
import 'data/services/storage_service.dart';
import 'data/services/api_service.dart';

// Global ViewModels
import 'viewmodels/settings_viewmodel.dart';

// Routes
import 'routes/app_pages.dart';

// Views
import 'views/home/home_screen.dart';
import 'views/graph/graph_screen.dart';
import 'views/converter/converter_screen.dart';
import 'views/zakat/zakat_screen.dart';
import 'views/settings/settings_screen.dart';
import 'views/widgets/bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize persistent storage service
  await Get.putAsync(() => StorageService().init());

  // 2. Initialize live pricing service
  await Get.putAsync(() => ApiService().init());

  // 3. Register global ViewModels
  Get.put(SettingsViewModel());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Build a rich dark ThemeData that applies to the entire app
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cardBgDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.bearish,
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textMutedDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary.withOpacity(0.3);
          return AppColors.borderDark;
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  // Build a premium light ThemeData
  static ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cardBgLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.bearish,
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textMutedLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary.withOpacity(0.3);
          return AppColors.borderLight;
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsViewModel settingsVm = Get.find<SettingsViewModel>();
    return Obx(() => GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: settingsVm.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ));
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    GraphScreen(symbol: 'XAU'),
    ConverterScreen(),
    ZakatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize responsive screen scaling proportions
    ScreenUtils.init(context);

    return Obx(() => Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    ));
  }
}
