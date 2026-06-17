abstract class Routes {
  static const SPLASH =
      '/splash';

  static const INITIAL =
      '/';

  // Pages
  static const HOME =
      '/home';
  static const CONVERTER =
      '/converter';
  static const ZAKAT =
      '/zakat';
  static const JEWELLERY =
      '/jewellery';
  static const SETTINGS =
      '/settings';

  // Feature pages
  static const GRAPH =
      '/graph';
}

abstract class AppRoutes {
  static const INITIAL =
      Routes
          .INITIAL;
  static const HOME =
      Routes.HOME;
  static const CONVERTER =
      Routes
          .CONVERTER;
  static const ZAKAT =
      Routes.ZAKAT;
  static const JEWELLERY =
      Routes
          .JEWELLERY;
  static const SETTINGS =
      Routes
          .SETTINGS;
  static const GRAPH =
      Routes.GRAPH;
}
