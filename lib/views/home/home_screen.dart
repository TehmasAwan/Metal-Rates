import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/colors.dart';
import '../../screen_utils.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../core/utils/formatter.dart';
import '../widgets/metal_card.dart';
import '../graph/graph_screen.dart';

class HomeScreen
    extends
        StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen>
  createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends
        State<
          HomeScreen
        >
    with
        TickerProviderStateMixin {
  late AnimationController
  _staggerController;
  late Animation<
    double
  >
  _headerFade;
  late Animation<
    Offset
  >
  _headerSlide;
  late Animation<
    double
  >
  _cardsFade;
  late Animation<
    Offset
  >
  _cardsSlide;
  late Animation<
    double
  >
  _shareFade;
  late Animation<
    Offset
  >
  _shareSlide;

  @override
  void initState() {
    super
        .initState();

    _staggerController =
        AnimationController(
          duration: const Duration(
            milliseconds:
                1200,
          ),
          vsync:
              this,
        );

    _headerFade =
        Tween<double>(
          begin:
              0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent:
                _staggerController,
            curve: const Interval(
              0.0,
              0.4,
              curve:
                  Curves.easeOut,
            ),
          ),
        );

    _headerSlide =
        Tween<Offset>(
          begin:
              const Offset(
                -0.2,
                0,
              ),
          end: Offset
              .zero,
        ).animate(
          CurvedAnimation(
            parent:
                _staggerController,
            curve: const Interval(
              0.0,
              0.4,
              curve:
                  Curves.easeOutCubic,
            ),
          ),
        );

    _cardsFade =
        Tween<double>(
          begin:
              0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent:
                _staggerController,
            curve: const Interval(
              0.2,
              0.7,
              curve:
                  Curves.easeOut,
            ),
          ),
        );

    _cardsSlide =
        Tween<Offset>(
          begin:
              const Offset(
                0,
                0.3,
              ),
          end: Offset
              .zero,
        ).animate(
          CurvedAnimation(
            parent:
                _staggerController,
            curve: const Interval(
              0.2,
              0.7,
              curve:
                  Curves.easeOutCubic,
            ),
          ),
        );

    _shareFade =
        Tween<double>(
          begin:
              0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent:
                _staggerController,
            curve: const Interval(
              0.5,
              0.9,
              curve:
                  Curves.easeOut,
            ),
          ),
        );

    _shareSlide =
        Tween<Offset>(
          begin:
              const Offset(
                0,
                0.5,
              ),
          end: Offset
              .zero,
        ).animate(
          CurvedAnimation(
            parent:
                _staggerController,
            curve: const Interval(
              0.5,
              0.9,
              curve:
                  Curves.easeOutCubic,
            ),
          ),
        );

    _staggerController
        .forward();
  }

  @override
  void dispose() {
    _staggerController
        .dispose();
    super.dispose();
  }

  String
  _flagForCurrency(
    String currency,
  ) {
    switch (currency) {
      case 'PKR':
        return '🇵🇰';
      case 'USD':
        return '🇺🇸';
      case 'INR':
        return '🇮🇳';
      case 'AED':
        return '🇦🇪';
      default:
        return '🌍';
    }
  }

  @override
  Widget build(
    BuildContext
    context,
  ) {
    final HomeViewModel
    homeVm = Get.put(
      HomeViewModel(),
    );
    final SettingsViewModel
    settingsVm =
        Get.find<
          SettingsViewModel
        >();

    return Obx(
      () => Scaffold(
        backgroundColor:
            AppColors
                .background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal:
                  16.w,
              vertical:
                  8.h,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ── Animated App Bar Header ──
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Menu + Title
                            Row(
                              children: [
                                Icon(
                                  Icons.menu,
                                  color: AppColors.textPrimary,
                                  size: 22,
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
                                Text(
                                  'MetalRates',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            // Currency Selector Pill
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 7.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 1.2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  14,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    settingsVm.selectedCurrency.value,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    _flagForCurrency(
                                      settingsVm.selectedCurrency.value,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Divider(
                          color: AppColors.cardBorder.withOpacity(
                            0.5,
                          ),
                          thickness: 0.8,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Updated At ──
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Text(
                      'Updated today at ${TimeOfDay.now().format(context)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),

                // ── Animated Metal Rate Cards ──
                SlideTransition(
                  position: _cardsSlide,
                  child: FadeTransition(
                    opacity: _cardsFade,
                    child: _buildMetalCards(
                      homeVm,
                      settingsVm,
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),

                // ── Animated Share Today's Rates Banner ──
                SlideTransition(
                  position: _shareSlide,
                  child: FadeTransition(
                    opacity: _shareFade,
                    child: _buildShareBanner(
                      homeVm,
                      settingsVm,
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget
  _buildMetalCards(
    HomeViewModel
    homeVm,
    SettingsViewModel
    settingsVm,
  ) {
    if (homeVm
        .rawRates
        .isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: 80
                .h,
          ),
          child: CircularProgressIndicator(
            color: AppColors
                .primary,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height:
              14.h,
        ),
        MetalCard(
          symbol:
              'XAU',
          name:
              'Gold',
          formattedPrice:
              homeVm.getFormattedPrice(
                'XAU',
              ),
          change24h:
              homeVm.getPercentageChange(
                'XAU',
              ),
          highPrice:
              homeVm.getFormattedHigh(
                'XAU',
              ),
          lowPrice: homeVm
              .getFormattedLow(
                'XAU',
              ),
          onTap: () => Get.to(
            () => const GraphScreen(
              symbol:
                  'XAU',
            ),
          ),
        ),
        MetalCard(
          symbol:
              'XAG',
          name:
              'Silver',
          formattedPrice:
              homeVm.getFormattedPrice(
                'XAG',
              ),
          change24h:
              homeVm.getPercentageChange(
                'XAG',
              ),
          highPrice:
              homeVm.getFormattedHigh(
                'XAG',
              ),
          lowPrice: homeVm
              .getFormattedLow(
                'XAG',
              ),
          onTap: () => Get.to(
            () => const GraphScreen(
              symbol:
                  'XAG',
            ),
          ),
        ),
        SizedBox(
          height:
              14.h,
        ),
        // Currency rates card (shown below Silver)
        Container(
          padding:
              EdgeInsets.all(
                16.w,
              ),
          decoration: BoxDecoration(
            color: AppColors
                .cardBackground,
            border: Border.all(
              color:
                  AppColors.cardBorder,
              width:
                  1.2,
            ),
            borderRadius:
                BorderRadius.circular(
                  20,
                ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Currency Rates',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(
                height:
                    10.h,
              ),
              // Show all currencies received from API (live / cached exchange rate)
              ..._buildCurrencyRows(
                homeVm,
              ),
            ],
          ),
        ),
        SizedBox(
          height:
              8.h,
        ),
      ],
    );
  }

  List<Widget>
  _buildCurrencyRows(
    HomeViewModel
    homeVm,
  ) {
    final Map<
      String,
      double
    >
    exchangeRates =
        homeVm
            .exchangeRatesSnapshot;

    // Stable order for UI
    final currencies =
        exchangeRates
            .keys
            .toList()
          ..sort();

    return currencies
        .map(
          (
            c,
          ) => _currencyRowInPkr(
            homeVm,
            c,
          ),
        )
        .toList();
  }

  Widget
  _currencyRowInPkr(
    HomeViewModel
    homeVm,
    String
    currency, {
    bool isPrimary =
        false,
  }) {
    // Uses ApiService exchangeRates which are relative to 1 USD.
    // We always display conversions into PKR:
    //   1 CUR = (PKR per USD) / (CUR per USD)  PKR
    final String
    label;
    switch (currency) {
      case 'USD':
        label =
            'US Dollar';
        break;
      case 'PKR':
        label =
            'Pakistani Rupee';
        break;
      case 'INR':
        label =
            'Indian Rupee';
        break;
      case 'AED':
        label =
            'UAE Dirham';
        break;
      case 'SAR':
        label =
            'Saudi Riyal';
        break;
      case 'QAR':
        label =
            'Qatar Riyal';
        break;
      case 'KWD':
        label =
            'Kuwaiti Dinar';
        break;
      case 'EGP':
        label =
            'Egypt Pound';
        break;
      case 'OMR':
        label =
            'Omani Rial';
        break;
      case 'BHD':
        label =
            'Bahraini Dinar';
        break;
      default:
        label =
            currency;
        break;
    }

    final double?
    pkrPerUsd = homeVm
        .getExchangeRateFor(
          'PKR',
        );
    final double?
    curPerUsd = homeVm
        .getExchangeRateFor(
          currency,
        );

    final String
    valueText;
    if (pkrPerUsd ==
            null ||
        curPerUsd ==
            null ||
        curPerUsd ==
            0) {
      valueText =
          'N/A';
    } else {
      final double
      pkrPerCur =
          pkrPerUsd /
          curPerUsd;
      valueText =
          isPrimary
          ? '${AppFormatter.formatNumber(pkrPerCur, decimalDigits: 2)} PKR'
          : '${AppFormatter.formatNumber(pkrPerCur, decimalDigits: 2)} PKR';
    }

    return Padding(
      padding:
          EdgeInsets.symmetric(
            vertical:
                4.h,
          ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            '1 $currency',
            style: TextStyle(
              fontSize:
                  12.sp,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors.textSecondary,
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              fontSize:
                  12.sp,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildShareBanner(
    HomeViewModel
    homeVm,
    SettingsViewModel
    settingsVm,
  ) {
    return GestureDetector(
      onTap: () async {
        if (homeVm
            .rawRates
            .isEmpty) {
          return;
        }
        final double
        goldChange =
            homeVm.getPercentageChange(
              'XAU',
            );
        final double
        silverChange =
            homeVm.getPercentageChange(
              'XAG',
            );
        final double
        platinumChange =
            homeVm.getPercentageChange(
              'XPT',
            );

        final String
        shareMessage =
            "🌟 Today's Precious Metal Rates 🌟\n\n"
            "Unit: ${settingsVm.selectedUnit.value}\n"
            "Currency: ${settingsVm.selectedCurrency.value}\n\n"
            "👑 Gold (24K): ${homeVm.getFormattedPrice('XAU')} (${goldChange >= 0 ? '▲ +' : '▼ '}${goldChange.toStringAsFixed(2)}%)\n"
            "🥈 Silver: ${homeVm.getFormattedPrice('XAG')} (${silverChange >= 0 ? '▲ +' : '▼ '}${silverChange.toStringAsFixed(2)}%)\n"
            "💿 Platinum: ${homeVm.getFormattedPrice('XPT')} (${platinumChange >= 0 ? '▲ +' : '▼ '}${platinumChange.toStringAsFixed(2)}%)\n\n"
            "Calculated with live prices on MetalRates app. 📈";

        await Share.share(
          shareMessage,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal:
              20.w,
          vertical:
              16.h,
        ),
        decoration: BoxDecoration(
          color: AppColors
              .cardBackground,
          border: Border.all(
            color: AppColors
                .primary
                .withOpacity(
                  0.3,
                ),
            width:
                1.2,
          ),
          borderRadius:
              BorderRadius.circular(
                20,
              ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Container(
              width:
                  36.w,
              height:
                  36.w,
              decoration: BoxDecoration(
                color: AppColors.bullish.withOpacity(
                  0.12,
                ),
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                Icons.share_rounded,
                color:
                    AppColors.bullish,
                size:
                    18,
              ),
            ),
            SizedBox(
              width:
                  12.w,
            ),
            Text(
              "Share Today's Rates",
              style: TextStyle(
                fontSize:
                    15.sp,
                fontWeight:
                    FontWeight.w700,
                color:
                    AppColors.bullish,
                letterSpacing:
                    0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
