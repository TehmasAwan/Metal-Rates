import 'dart:math';
import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../data/models/metal_rate.dart';
import 'settings_viewmodel.dart';
import '../core/utils/formatter.dart';

class CandleData {
  final String date;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

class GraphViewModel extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SettingsViewModel _settingsVm = Get.find<SettingsViewModel>();

  final RxString selectedSymbol = 'XAU'.obs; // Default Gold
  final RxString selectedTimeframe = '7D'.obs; // 1D, 7D, 30D
  final RxString chartType = 'candlestick'.obs; // 'candlestick' or 'line'

  void setSymbol(String symbol) {
    selectedSymbol.value = symbol;
  }

  void setTimeframe(String timeframe) {
    selectedTimeframe.value = timeframe;
  }

  void toggleChartType() {
    if (chartType.value == 'candlestick') {
      chartType.value = 'line';
    } else {
      chartType.value = 'candlestick';
    }
  }

  MetalRate? get currentMetal => _apiService.rates[selectedSymbol.value];

  // Retrieve converted and scaled history data points for plotting
  List<double> getPlotData() {
    MetalRate? rate = currentMetal;
    if (rate == null) {
      return [];
    }

    List<double> rawHistory;
    if (selectedTimeframe.value == '1D') {
      rawHistory = rate.history1d;
    } else if (selectedTimeframe.value == '30D') {
      rawHistory = rate.history30d;
    } else {
      rawHistory = rate.history7d;
    }

    String cur = _settingsVm.selectedCurrency.value;
    double exRate = _apiService.exchangeRates[cur] ?? 1.0;
    String unit = _settingsVm.selectedUnit.value;

    final converted = rawHistory.map((usdPrice) {
      // Keep Graph conversion identical to Home conversion: 24K baseline, then apply unit+currency.
      // AppFormatter.convertPrice already handles unit conversion for Gram/Tola/Ounce.
      return AppFormatter.convertPrice(
        basePriceUsdPerOz: usdPrice,
        exchangeRateUsdToTarget: exRate,
        targetUnit: unit,
        purityMultiplier: 1.0,
      );
    }).toList();

    // Force the last plotted point to equal HomeViewModel's current price
    // (prevents mismatches when hot reload happens during simulation).
    if (converted.isNotEmpty) {
      converted[converted.length - 1] = AppFormatter.convertPrice(
        basePriceUsdPerOz: rate.priceUsd,
        exchangeRateUsdToTarget: exRate,
        targetUnit: unit,
        purityMultiplier: 1.0,
      );
    }

    return converted;
  }

  // Generate realistic, consistent, and seeded OHLC data points
  List<CandleData> getCandleData() {
    List<double> plotPrices = getPlotData();
    if (plotPrices.isEmpty) {
      return [];
    }

    List<CandleData> candles = [];
    final random = Random(42); // Seeded for consistency

    for (int i = 0; i < plotPrices.length; i++) {
      double close = plotPrices[i];
      // The open price is the previous close price (or 99.5% of current close for the first element)
      double open = i == 0 ? close * 0.995 : plotPrices[i - 1];

      // Standard visual wiggle room for high/low wicks
      double wiggle = close * 0.003;
      double high = max(open, close) + (random.nextDouble() * wiggle);
      double low = min(open, close) - (random.nextDouble() * wiggle);

      // Ensure sanity constraints
      if (high < max(open, close)) {
        high = max(open, close);
      }
      if (low > min(open, close)) {
        low = min(open, close);
      }

      // Labeling dates/times (no DateTime.now() so hot reload never changes labels/values)
      // Deterministic based on index.
      String label = '';
      if (selectedTimeframe.value == '1D') {
        final int hour = 9 + i;
        label =
            '${hour % 12 == 0 ? 12 : hour % 12}:00 ${hour >= 12 ? 'PM' : 'AM'}';
      } else {
        label = 'Day ${i + 1}';
      }

      candles.add(
        CandleData(date: label, open: open, high: high, low: low, close: close),
      );
    }

    return candles;
  }

  // Statistics calculation for the current chart selection
  double getMinVal() {
    List<double> data = getPlotData();
    return data.isEmpty ? 0.0 : data.reduce(min);
  }

  double getMaxVal() {
    List<double> data = getPlotData();
    return data.isEmpty ? 0.0 : data.reduce(max);
  }

  double getAverageVal() {
    List<double> data = getPlotData();
    if (data.isEmpty) {
      return 0.0;
    }
    double total = data.reduce((a, b) => a + b);
    return total / data.length;
  }

  String formatValue(double val) {
    return AppFormatter.formatCurrency(val, _settingsVm.selectedCurrency.value);
  }
}
