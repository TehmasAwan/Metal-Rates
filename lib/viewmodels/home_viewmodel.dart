import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../data/models/metal_rate.dart';
import 'settings_viewmodel.dart';
import '../core/utils/formatter.dart';

class HomeViewModel
    extends
        GetxController {
  final ApiService
  _apiService =
      Get.find<
        ApiService
      >();
  final SettingsViewModel
  _settingsVm =
      Get.find<
        SettingsViewModel
      >();

  // Fetch reactive rates from api service
  RxMap<
    String,
    MetalRate
  >
  get rawRates =>
      _apiService
          .rates;

  // Exchange rates relative to 1 USD
  // (live when ApiService.fetchLiveRates() succeeds; otherwise cached values remain)
  Map<
    String,
    double
  >
  get exchangeRatesSnapshot =>
      Map<
        String,
        double
      >.from(
        _apiService
            .exchangeRates,
      );

  // Track exchange rates
  // Exchange rate relative to 1 USD for a specific currency.
  double?
  getExchangeRateFor(
    String
    currencyCode,
  ) {
    return _apiService
        .exchangeRates[currencyCode];
  }

  double
  getExchangeRate() {
    String
    cur = _settingsVm
        .selectedCurrency
        .value;
    return _apiService
            .exchangeRates[cur] ??
        1.0;
  }

  // Get formatted price for a specific metal symbol (e.g. XAU)
  String
  getFormattedPrice(
    String symbol,
  ) {
    MetalRate?
    rate =
        rawRates[symbol];
    if (rate ==
        null) {
      return '';
    }

    double
    converted = AppFormatter.convertPrice(
      basePriceUsdPerOz:
          rate.priceUsd,
      exchangeRateUsdToTarget:
          getExchangeRate(),
      targetUnit:
          _settingsVm
              .selectedUnit
              .value,
      purityMultiplier:
          1.0, // 24K baseline
    );

    return AppFormatter.formatCurrency(
      converted,
      _settingsVm
          .selectedCurrency
          .value,
    );
  }

  // Get formatted daily High
  String
  getFormattedHigh(
    String symbol,
  ) {
    MetalRate?
    rate =
        rawRates[symbol];
    if (rate ==
        null) {
      return '';
    }
    double
    converted = AppFormatter.convertPrice(
      basePriceUsdPerOz:
          rate.high24h,
      exchangeRateUsdToTarget:
          getExchangeRate(),
      targetUnit:
          _settingsVm
              .selectedUnit
              .value,
      purityMultiplier:
          1.0,
    );
    return AppFormatter.formatCurrency(
      converted,
      _settingsVm
          .selectedCurrency
          .value,
    );
  }

  // Get formatted daily Low
  String
  getFormattedLow(
    String symbol,
  ) {
    MetalRate?
    rate =
        rawRates[symbol];
    if (rate ==
        null) {
      return '';
    }
    double
    converted = AppFormatter.convertPrice(
      basePriceUsdPerOz:
          rate.low24h,
      exchangeRateUsdToTarget:
          getExchangeRate(),
      targetUnit:
          _settingsVm
              .selectedUnit
              .value,
      purityMultiplier:
          1.0,
    );
    return AppFormatter.formatCurrency(
      converted,
      _settingsVm
          .selectedCurrency
          .value,
    );
  }

  // Raw price conversion for calculation packages (always return 24K per gram for core math)
  double
  getPricePerGram24K(
    String symbol,
  ) {
    MetalRate?
    rate =
        rawRates[symbol];
    if (rate ==
        null) {
      return 0.0;
    }

    return AppFormatter.convertPrice(
      basePriceUsdPerOz:
          rate.priceUsd,
      exchangeRateUsdToTarget:
          getExchangeRate(),
      targetUnit:
          'Gram (g)',
      purityMultiplier:
          1.0,
    );
  }

  double
  getPercentageChange(
    String symbol,
  ) {
    return rawRates[symbol]
            ?.change24h ??
        0.0;
  }
}
