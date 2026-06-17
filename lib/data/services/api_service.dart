import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart'
    as http;
import '../../core/constants/api_keys.dart';
import '../models/metal_rate.dart';

class ApiService
    extends
        GetxService {
  final RxMap<
    String,
    MetalRate
  >
  rates =
      <
            String,
            MetalRate
          >{}
          .obs;

  // Real-time market tick controller and API sync timer
  Timer? _ticker;
  Timer?
  _apiSyncTimer;
  final _random =
      Random();

  // Exchange rates relative to 1 USD
  final Map<
    String,
    double
  >
  exchangeRates = {
    'USD': 1.0,
    'PKR': 278.50,
    'INR': 83.50,
    'AED': 3.673,
  };

  // Base API prices cache (to lock micro-fluctuations close to actual API prices)
  double?
  _apiBaseGold;
  double?
  _apiBaseSilver;

  // Metal Base Prices (USD per Troy Ounce)
  // XAU = Gold, XAG = Silver, XPT = Platinum
  static const double
  baseGold =
      2350.50;
  static const double
  baseSilver =
      29.80;
  static const double
  basePlatinum =
      975.20;

  Future<ApiService>
  init() async {
    _initializeRates();
    if (ApiKeys
        .useLiveApi) {
      await fetchLiveRates();
      // Sync with API every 2 minutes
      _apiSyncTimer =
          Timer.periodic(
            const Duration(
              minutes:
                  2,
            ),
            (
              timer,
            ) {
              fetchLiveRates();
            },
          );
    }
    // If using live API, don't overwrite API prices with simulation.
    if (!ApiKeys
        .useLiveApi) {
      _startSimulation();
    }
    return this;
  }

  void
  _initializeRates() {
    rates['XAU'] =
        _generateInitialMetal(
          'XAU',
          'Gold',
          baseGold,
        );
    rates['XAG'] =
        _generateInitialMetal(
          'XAG',
          'Silver',
          baseSilver,
        );
    rates['XPT'] =
        _generateInitialMetal(
          'XPT',
          'Platinum',
          basePlatinum,
        );
  }

  MetalRate
  _generateInitialMetal(
    String symbol,
    String name,
    double
    basePrice,
  ) {
    List<double>
    hist1d = [];
    double current =
        basePrice *
        0.98;
    for (
      int i = 0;
      i < 12;
      i++
    ) {
      current +=
          (current *
          (_random.nextDouble() -
              0.48) *
          0.015);
      hist1d.add(
        current,
      );
    }

    List<double>
    hist7d = [];
    current =
        basePrice *
        0.95;
    for (
      int i = 0;
      i < 7;
      i++
    ) {
      current +=
          (current *
          (_random.nextDouble() -
              0.49) *
          0.025);
      hist7d.add(
        current,
      );
    }

    List<double>
    hist30d = [];
    current =
        basePrice *
        0.90;
    for (
      int i = 0;
      i < 30;
      i++
    ) {
      current +=
          (current *
          (_random.nextDouble() -
              0.49) *
          0.04);
      hist30d.add(
        current,
      );
    }

    double
    finalPrice =
        hist1d.last;
    double high =
        hist1d
            .reduce(
              max,
            );
    double low =
        hist1d
            .reduce(
              min,
            );

    double
    initialPrice =
        hist1d
            .first;
    double
    pctChange =
        ((finalPrice -
                initialPrice) /
            initialPrice) *
        100;

    return MetalRate(
      symbol:
          symbol,
      name: name,
      priceUsd:
          finalPrice,
      change24h:
          pctChange,
      high24h: max(
        high,
        finalPrice,
      ),
      low24h: min(
        low,
        finalPrice,
      ),
      history1d:
          hist1d,
      history7d:
          hist7d,
      history30d:
          hist30d,
    );
  }

  Future<void>
  fetchLiveRates() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiKeys
                  .metalApiBaseUrl,
            ).replace(
              queryParameters: {
                'period':
                    '7d',
              },
            ),
            headers: {
              'accept':
                  'application/json',
              'x-api-key':
                  ApiKeys.metalApiKey,
            },
          )
          .timeout(
            const Duration(
              seconds:
                  10,
            ),
          );

      if (response
              .statusCode ==
          200) {
        final data =
            json.decode(
              response
                  .body,
            );
        if (data['success'] ==
            true) {
          _parseApiResponse(
            data,
          );
        }
      }
    } catch (e) {
      // Graceful error logging - keeps simulated/existing rates intact
      Get.log(
        'ApiService Error fetching live rates: $e',
      );
    }
  }

  void
  _parseApiResponse(
    Map<
      String,
      dynamic
    >
    data,
  ) {
    final current =
        data['current'];
    if (current ==
        null) {
      return;
    }

    // 1. Update Exchange Rates
    final currencies =
        current['currencies'];
    if (currencies !=
        null) {
      currencies.forEach((
        key,
        val,
      ) {
        if (val !=
                null &&
            val['today'] !=
                null) {
          exchangeRates[key] =
              (val['today']
                      as num)
                  .toDouble();
        }
      });
    }

    // 2. Parse Gold ("XAU")
    final goldData =
        current['metals']?['gold'];
    final goldSpot =
        data['spot']?['gold'];
    if (goldData !=
        null) {
      final priceUsd =
          (goldData['prices']?['USD']?['today']
                  as num?)
              ?.toDouble() ??
          baseGold;
      _apiBaseGold =
          priceUsd;
      final change24h =
          (goldSpot?['percent']
                  as num?)
              ?.toDouble() ??
          (goldData['change_summary']?['label'] !=
                  null
              ? double.tryParse(
                      (goldData['change_summary']['label']
                              as String)
                          .replaceAll(
                            '%',
                            '',
                          ),
                    ) ??
                    0.0
              : 0.0);
      final high24h =
          (goldSpot?['high']
                  as num?)
              ?.toDouble() ??
          priceUsd;
      final low24h =
          (goldSpot?['low']
                  as num?)
              ?.toDouble() ??
          priceUsd;

      // Parse graph/history
      final graphPoints =
          data['graph']?['metals']?['gold']?['data_points']
              as List?;
      List<double>
      parsedHistory =
          [];
      if (graphPoints !=
          null) {
        for (var pt
            in graphPoints) {
          final usdVal =
              pt['prices']?['USD']
                  as num?;
          if (usdVal !=
              null) {
            parsedHistory.add(
              usdVal
                  .toDouble(),
            );
          }
        }
      }

      // Pad / format histories
      List<double>
      history30d =
          _padHistory(
            parsedHistory,
            30,
            priceUsd,
          );
      List<double>
      history7d =
          _padHistory(
            parsedHistory,
            7,
            priceUsd,
          );
      List<double>
      history1d =
          rates['XAU']
              ?.history1d ??
          List.filled(
            12,
            priceUsd,
          );
      if (history1d
              .isEmpty ||
          history1d
                  .length <
              12) {
        history1d =
            List.filled(
              12,
              priceUsd,
            );
      }

      rates['XAU'] = MetalRate(
        symbol:
            'XAU',
        name:
            'Gold',
        priceUsd:
            priceUsd,
        change24h:
            change24h,
        high24h:
            high24h,
        low24h:
            low24h,
        history1d:
            history1d,
        history7d:
            history7d,
        history30d:
            history30d,
      );
    }

    // 3. Parse Silver ("XAG")
    final silverData =
        current['metals']?['silver'];
    final silverSpot =
        data['spot']?['silver'];
    if (silverData !=
        null) {
      final priceUsd =
          (silverData['prices']?['USD']?['today']
                  as num?)
              ?.toDouble() ??
          baseSilver;
      _apiBaseSilver =
          priceUsd;
      final change24h =
          (silverSpot?['percent']
                  as num?)
              ?.toDouble() ??
          (silverData['change_summary']?['label'] !=
                  null
              ? double.tryParse(
                      (silverData['change_summary']['label']
                              as String)
                          .replaceAll(
                            '%',
                            '',
                          ),
                    ) ??
                    0.0
              : 0.0);
      final high24h =
          (silverSpot?['high']
                  as num?)
              ?.toDouble() ??
          priceUsd;
      final low24h =
          (silverSpot?['low']
                  as num?)
              ?.toDouble() ??
          priceUsd;

      // Parse graph/history
      final graphPoints =
          data['graph']?['metals']?['silver']?['data_points']
              as List?;
      List<double>
      parsedHistory =
          [];
      if (graphPoints !=
          null) {
        for (var pt
            in graphPoints) {
          final usdVal =
              pt['prices']?['USD']
                  as num?;
          if (usdVal !=
              null) {
            parsedHistory.add(
              usdVal
                  .toDouble(),
            );
          }
        }
      }

      // Pad / format histories
      List<double>
      history30d =
          _padHistory(
            parsedHistory,
            30,
            priceUsd,
          );
      List<double>
      history7d =
          _padHistory(
            parsedHistory,
            7,
            priceUsd,
          );
      List<double>
      history1d =
          rates['XAG']
              ?.history1d ??
          List.filled(
            12,
            priceUsd,
          );
      if (history1d
              .isEmpty ||
          history1d
                  .length <
              12) {
        history1d =
            List.filled(
              12,
              priceUsd,
            );
      }

      rates['XAG'] = MetalRate(
        symbol:
            'XAG',
        name:
            'Silver',
        priceUsd:
            priceUsd,
        change24h:
            change24h,
        high24h:
            high24h,
        low24h:
            low24h,
        history1d:
            history1d,
        history7d:
            history7d,
        history30d:
            history30d,
      );
    }

    // 4. Parse Platinum ("XPT")
    // Website may show live platinum; app previously used simulated values for XPT.
    final platinumData =
        current['metals']?['platinum'];
    final platinumSpot =
        data['spot']?['platinum'];
    if (platinumData !=
        null) {
      final priceUsd =
          (platinumData['prices']?['USD']?['today']
                  as num?)
              ?.toDouble() ??
          basePlatinum;
      final change24h =
          (platinumSpot?['percent']
                  as num?)
              ?.toDouble() ??
          (platinumData['change_summary']?['label'] !=
                  null
              ? double.tryParse(
                      (platinumData['change_summary']['label']
                              as String)
                          .replaceAll(
                            '%',
                            '',
                          ),
                    ) ??
                    0.0
              : 0.0);
      final high24h =
          (platinumSpot?['high']
                  as num?)
              ?.toDouble() ??
          priceUsd;
      final low24h =
          (platinumSpot?['low']
                  as num?)
              ?.toDouble() ??
          priceUsd;

      // Parse graph/history
      final graphPoints =
          data['graph']?['metals']?['platinum']?['data_points']
              as List?;
      List<double>
      parsedHistory =
          [];
      if (graphPoints !=
          null) {
        for (var pt
            in graphPoints) {
          final usdVal =
              pt['prices']?['USD']
                  as num?;
          if (usdVal !=
              null) {
            parsedHistory.add(
              usdVal
                  .toDouble(),
            );
          }
        }
      }

      List<double>
      history30d =
          _padHistory(
            parsedHistory,
            30,
            priceUsd,
          );
      List<double>
      history7d =
          _padHistory(
            parsedHistory,
            7,
            priceUsd,
          );
      List<double>
      history1d =
          rates['XPT']
              ?.history1d ??
          List.filled(
            12,
            priceUsd,
          );
      if (history1d
              .isEmpty ||
          history1d
                  .length <
              12) {
        history1d =
            List.filled(
              12,
              priceUsd,
            );
      }

      rates['XPT'] = MetalRate(
        symbol:
            'XPT',
        name:
            'Platinum',
        priceUsd:
            priceUsd,
        change24h:
            change24h,
        high24h:
            high24h,
        low24h:
            low24h,
        history1d:
            history1d,
        history7d:
            history7d,
        history30d:
            history30d,
      );
    }
  }

  // Pad/slice history lists to match target sizes
  List<double>
  _padHistory(
    List<double>
    raw,
    int targetSize,
    double
    fallbackVal,
  ) {
    if (raw
        .isEmpty) {
      return List.filled(
        targetSize,
        fallbackVal,
      );
    }
    List<double>
    result =
        List<
          double
        >.from(raw);
    if (result
            .length >
        targetSize) {
      return result.sublist(
        result.length -
            targetSize,
      );
    }
    while (result
            .length <
        targetSize) {
      result.insert(
        0,
        result
            .first,
      );
    }
    return result;
  }

  void
  _startSimulation() {
    _ticker = Timer.periodic(
      const Duration(
        minutes: 2,
      ),
      (timer) {
        rates.forEach((
          symbol,
          metal,
        ) {
          // Multiplier: -0.4% to +0.42% for realistic tiny variations
          double
          tickPercentChange =
              (_random.nextDouble() -
                  0.48) *
              0.002;
          double
          newPrice =
              metal
                  .priceUsd *
              (1.0 +
                  tickPercentChange);

          // If using live API and base price exists, constrain Gold and Silver to +/- 0.1% of API base price
          if (ApiKeys
              .useLiveApi) {
            if (symbol ==
                    'XAU' &&
                _apiBaseGold !=
                    null) {
              double
              lowerBound =
                  _apiBaseGold! *
                  0.999;
              double
              upperBound =
                  _apiBaseGold! *
                  1.001;
              newPrice = max(
                lowerBound,
                min(
                  upperBound,
                  newPrice,
                ),
              );
            } else if (symbol ==
                    'XAG' &&
                _apiBaseSilver !=
                    null) {
              double
              lowerBound =
                  _apiBaseSilver! *
                  0.999;
              double
              upperBound =
                  _apiBaseSilver! *
                  1.001;
              newPrice = max(
                lowerBound,
                min(
                  upperBound,
                  newPrice,
                ),
              );
            }
          }

          double
          newHigh = max(
            metal
                .high24h,
            newPrice,
          );
          double
          newLow = min(
            metal
                .low24h,
            newPrice,
          );

          // Shift/apply new price to every timeframe so 1D/7D/30D are consistent during runtime.
          List<
            double
          >
          updated1d =
              List<
                double
              >.from(
                metal.history1d,
              );
          if (updated1d
              .isNotEmpty) {
            updated1d
                .removeAt(
                  0,
                );
          }
          updated1d.add(
            newPrice,
          );

          List<
            double
          >
          updated7d =
              List<
                double
              >.from(
                metal.history7d,
              );
          if (updated7d
              .isNotEmpty) {
            updated7d
                .removeAt(
                  0,
                );
          }
          updated7d.add(
            newPrice,
          );

          List<
            double
          >
          updated30d =
              List<
                double
              >.from(
                metal.history30d,
              );
          if (updated30d
              .isNotEmpty) {
            updated30d
                .removeAt(
                  0,
                );
          }
          updated30d
              .add(
                newPrice,
              );

          // Calculate simulated 24h percent change based on 1D window unless live API should be used.
          double
          firstPrice =
              updated1d
                  .isNotEmpty
              ? updated1d.first
              : newPrice;
          double
          pctChange =
              firstPrice !=
                  0
              ? ((newPrice -
                            firstPrice) /
                        firstPrice) *
                    100
              : 0.0;

          // Keep 24h percentage change from live API spot data rather than calculating over 1D ticks,
          // because 1D history starts with flat values when first parsed
          double
          finalChange =
              (ApiKeys.useLiveApi &&
                  symbol !=
                      'XPT')
              ? metal.change24h
              : pctChange;

          rates[symbol] = metal.copyWith(
            priceUsd:
                newPrice,
            change24h:
                finalChange,
            high24h:
                newHigh,
            low24h:
                newLow,
            history1d:
                updated1d,
            history7d:
                updated7d,
            history30d:
                updated30d,
          );
        });
      },
    );
  }

  Future<bool>
  subscribeAlert({
    required String
    metal,
    required String
    currency,
    required double
    target,
    required String
    condition,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              'https://www.metal.hassaanahmad.dev/api/alerts/subscribe',
            ),
            headers: {
              'accept':
                  'application/json',
              'x-api-key':
                  ApiKeys.metalApiKey,
              'Content-Type':
                  'application/json',
            },
            body: json.encode({
              'fcm_token':
                  'device_fcm_token',
              'metal':
                  metal.toLowerCase(),
              'currency':
                  currency,
              'target':
                  target,
              'condition':
                  condition,
              'active':
                  true,
            }),
          )
          .timeout(
            const Duration(
              seconds:
                  10,
            ),
          );

      if (response.statusCode ==
              200 ||
          response.statusCode ==
              201) {
        final data =
            json.decode(
              response
                  .body,
            );
        return data['success'] ==
            true;
      }
      return false;
    } catch (e) {
      Get.log(
        'ApiService Error subscribing alert: $e',
      );
      return false;
    }
  }

  Future<bool>
  unsubscribeAlerts() async {
    try {
      final response = await http
          .post(
            Uri.parse(
              'https://www.metal.hassaanahmad.dev/api/alerts/unsubscribe',
            ),
            headers: {
              'accept':
                  'application/json',
              'x-api-key':
                  ApiKeys.metalApiKey,
              'Content-Type':
                  'application/json',
            },
            body: json.encode({
              'fcm_token':
                  'device_fcm_token',
            }),
          )
          .timeout(
            const Duration(
              seconds:
                  10,
            ),
          );

      if (response.statusCode ==
              200 ||
          response.statusCode ==
              201) {
        final data =
            json.decode(
              response
                  .body,
            );
        return data['success'] ==
            true;
      }
      return false;
    } catch (e) {
      Get.log(
        'ApiService Error unsubscribing alerts: $e',
      );
      return false;
    }
  }

  @override
  void onClose() {
    _ticker
        ?.cancel();
    _apiSyncTimer
        ?.cancel();
    super.onClose();
  }
}
