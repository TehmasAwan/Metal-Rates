import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../screen_utils.dart';
import '../../viewmodels/converter_viewmodel.dart';
import '../../viewmodels/jewellery_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

class ConverterScreen
    extends
        StatefulWidget {
  const ConverterScreen({
    super.key,
  });

  @override
  State<
    ConverterScreen
  >
  createState() =>
      _ConverterScreenState();
}

class _ConverterScreenState
    extends
        State<
          ConverterScreen
        > {
  int _tabIndex =
      0; // 0 = Metal Converter, 1 = Jewellery Estimator

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
    final ConverterViewModel
    cvVm = Get.put(
      ConverterViewModel(),
    );
    final JewelleryViewModel
    jwVm = Get.put(
      JewelleryViewModel(),
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
                // ── App Bar Header ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Obx(
                      () => Container(
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
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.h,
                ),

                // ── Tab Switcher ──
                Container(
                  padding: const EdgeInsets.all(
                    4,
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
                    children: [
                      _buildTabButton(
                        0,
                        'Metal Converter',
                      ),
                      _buildTabButton(
                        1,
                        'Jewellery Estimator',
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),

                // ── Tab Content ──
                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  child:
                      _tabIndex ==
                          0
                      ? _buildMetalConverterView(
                          cvVm,
                          settingsVm,
                        )
                      : _buildJewelleryEstimatorView(
                          jwVm,
                          settingsVm,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget
  _buildTabButton(
    int index,
    String label,
  ) {
    bool
    isSelected =
        _tabIndex ==
        index;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(
              () => _tabIndex =
                  index,
            ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds:
                200,
          ),
          padding: EdgeInsets.symmetric(
            vertical:
                11.h,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                ? AppColors.primary
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(
                  11,
                ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize:
                    12.sp,
                fontWeight:
                    FontWeight.w700,
                color:
                    isSelected
                    ? Colors.black
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  METAL CONVERTER VIEW (Image 4)
  // ══════════════════════════════════════════════════════
  Widget
  _buildMetalConverterView(
    ConverterViewModel
    cvVm,
    SettingsViewModel
    settingsVm,
  ) {
    return Column(
      key: const ValueKey(
        'metal_converter',
      ),
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        // Title
        Text(
          'Metal Converter',
          style: TextStyle(
            fontSize:
                26.sp,
            fontWeight:
                FontWeight.w900,
            color: AppColors
                .textPrimary,
            letterSpacing:
                -0.5,
          ),
        ),
        Text(
          'Real-time valuation based on market spot prices.',
          style: TextStyle(
            fontSize:
                12.sp,
            color: AppColors
                .textSecondary,
            fontWeight:
                FontWeight.w500,
          ),
        ),
        SizedBox(
          height:
              18.h,
        ),

        // Weight Input
        _buildInputLabel(
          'WEIGHT',
        ),
        SizedBox(
          height:
              8.h,
        ),
        Obx(
          () => TextField(
            controller:
                cvVm.weightController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal:
                  true,
            ),
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontSize:
                  22.sp,
              fontWeight:
                  FontWeight.w800,
            ),
            decoration: _inputDecoration(
              suffixWidget: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: Text(
                  cvVm.sourceUnit.value ==
                          'Gram (g)'
                      ? 'Grams'
                      : cvVm.sourceUnit.value ==
                            'Tola'
                      ? 'Tola'
                      : 'Ounce',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            onChanged:
                cvVm.convertFromWeight,
          ),
        ),
        SizedBox(
          height:
              18.h,
        ),

        // Metal Selector
        _buildInputLabel(
          'METAL',
        ),
        SizedBox(
          height:
              8.h,
        ),
        Obx(
          () => Row(
            children: [
              _buildMetalPill(
                cvVm,
                'XAU',
                'Gold',
              ),
              _buildMetalPill(
                cvVm,
                'XAG',
                'Silver',
              ),
              _buildMetalPill(
                cvVm,
                'XPT',
                'Platinum',
              ),
            ],
          ),
        ),
        SizedBox(
          height:
              18.h,
        ),

        // Karat Selector
        _buildInputLabel(
          'KARAT',
        ),
        SizedBox(
          height:
              8.h,
        ),
        Obx(
          () => Row(
            children:
                [
                  '24K',
                  '22K',
                  '21K',
                  '18K',
                ].map((
                  k,
                ) {
                  bool
                  isSel =
                      cvVm.selectedKarat.value ==
                      k;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => cvVm.updateCarat(
                        k,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 3,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primary
                              : AppColors.cardBackground,
                          border: Border.all(
                            color: isSel
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            k,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isSel
                                  ? Colors.black
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),

        SizedBox(
          height:
              18.h,
        ),

        // Unit Selector
        _buildInputLabel(
          'UNIT',
        ),
        SizedBox(
          height:
              8.h,
        ),
        Obx(
          () => Row(
            children:
                [
                  'Gram (g)',
                  'Tola',
                  'Ounce (oz)',
                ].map((
                  u,
                ) {
                  bool
                  isSel =
                      cvVm.sourceUnit.value ==
                      u;
                  String
                  label =
                      u ==
                          'Gram (g)'
                      ? 'Gram'
                      : u ==
                            'Tola'
                      ? 'Tola'
                      : 'Ounce';
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => cvVm.selectSourceUnit(
                        u,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 3,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primary
                              : AppColors.cardBackground,
                          border: Border.all(
                            color: isSel
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isSel
                                  ? Colors.black
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        SizedBox(
          height:
              24.h,
        ),

        // Estimated Value Card
        Obx(
          () => Container(
            width: double
                .infinity,
            padding:
                EdgeInsets.all(
                  20.w,
                ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(
                    0.08,
                  ),
                  AppColors.cardBackground,
                ],
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(
                  0.3,
                ),
                width:
                    1.5,
              ),
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'ESTIMATED VALUE',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  cvVm.formatCurrency(
                    cvVm.calculatedCash.value,
                  ),
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(
                  height: 6.h,
                ),
                Text(
                  '${cvVm.selectedMetal.value == 'XAU'
                      ? 'Gold'
                      : cvVm.selectedMetal.value == 'XAG'
                      ? 'Silver'
                      : 'Platinum'} ${cvVm.selectedKarat.value} · ${cvVm.weightController.text} ${cvVm.sourceUnit.value == 'Gram (g)'
                      ? 'grams'
                      : cvVm.sourceUnit.value == 'Tola'
                      ? 'tola'
                      : 'oz'}',

                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 12.h,
                ),
                Divider(
                  color: AppColors.cardBorder,
                  thickness: 0.8,
                ),
                SizedBox(
                  height: 8.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 14,
                          color: AppColors.bullish,
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Text(
                          '+1.2% Today',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.bullish,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Share Quote',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Icon(
                          Icons.share_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height:
              16.h,
        ),

        // Live Market Data Info
        Container(
          padding:
              EdgeInsets.all(
                14.w,
              ),
          decoration: BoxDecoration(
            color: AppColors
                .cardBackground,
            border: Border.all(
              color:
                  AppColors.cardBorder,
            ),
            borderRadius:
                BorderRadius.circular(
                  16,
                ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width:
                    32.w,
                height:
                    32.w,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(
                    0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.accent,
                  size: 16,
                ),
              ),
              SizedBox(
                width:
                    10.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Market Data',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Text(
                      'Rates are updated every 2 minutes. Final transaction value may vary based on jeweler premiums and taxes.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height:
              24.h,
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  //  JEWELLERY ESTIMATOR VIEW (Image 3)
  // ══════════════════════════════════════════════════════
  Widget
  _buildJewelleryEstimatorView(
    JewelleryViewModel
    jwVm,
    SettingsViewModel
    settingsVm,
  ) {
    return Column(
      key: const ValueKey(
        'jewellery_estimator',
      ),
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        // Title with icon
        Row(
          children: [
            Container(
              width:
                  42.w,
              height:
                  42.w,
              decoration: BoxDecoration(
                gradient:
                    AppColors.goldGradient,
                shape:
                    BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond_outlined,
                color:
                    Colors.black87,
                size:
                    20,
              ),
            ),
            SizedBox(
              width:
                  12.w,
            ),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Jewellery Estimator',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Calculate value with live market precision',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height:
              20.h,
        ),

        // Form Card
        Container(
          padding:
              EdgeInsets.all(
                18.w,
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
                  22,
                ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // Weight
              Obx(() => _buildInputLabel(
                jwVm.selectedWeightUnit.value == 'Tola'
                    ? 'WEIGHT IN TOLAS'
                    : 'WEIGHT IN GRAMS',
              )),
              SizedBox(
                height:
                    8.h,
              ),
              Obx(() => TextField(
                controller:
                    jwVm.weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                decoration: _inputDecoration(
                  suffixText: jwVm.selectedWeightUnit.value == 'Tola' ? 'tola' : 'g',
                ),
                onChanged: (_) =>
                    jwVm.calculate(),
              )),
              SizedBox(
                height:
                    18.h,
              ),

              // Unit Selector
              _buildInputLabel(
                'UNIT',
              ),
              SizedBox(
                height:
                    8.h,
              ),
              Obx(
                () => Row(
                  children: ['Gram (g)', 'Tola'].map(
                    (unit) {
                      bool isSel = jwVm.selectedWeightUnit.value == unit;
                      String label = unit == 'Gram (g)' ? 'Gram' : 'Tola';
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => jwVm.toggleWeightUnit(unit),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 3,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.background,
                              border: Border.all(
                                color: isSel
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                              ),
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isSel
                                      ? Colors.black
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              SizedBox(
                height:
                    18.h,
              ),

              // Purity (Karat)
              _buildInputLabel(
                'PURITY (KARAT)',
              ),
              SizedBox(
                height:
                    8.h,
              ),
              Obx(
                () => Row(
                  children: jwVm.caratsList.map(
                    (
                      carat,
                    ) {
                      bool isSel =
                          jwVm.selectedCarat.value ==
                          carat;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => jwVm.updateCarat(
                            carat,
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 3,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.background,
                              border: Border.all(
                                color: isSel
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                              ),
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                carat,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isSel
                                      ? Colors.black
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              SizedBox(
                height:
                    18.h,
              ),

              // Making Charges
              _buildInputLabel(
                'MAKING CHARGES (%)',
              ),
              SizedBox(
                height:
                    8.h,
              ),
              TextField(
                controller:
                    jwVm.makingChargesController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                decoration: _inputDecoration(
                  suffixText: '%',
                ),
                onChanged: (_) =>
                    jwVm.calculate(),
              ),
            ],
          ),
        ),
        SizedBox(
          height:
              20.h,
        ),

        // Estimate Breakdown Card
        Obx(() {
          double
          makingVal =
              double.tryParse(
                jwVm.makingChargesController.text,
              ) ??
              0.0;
          double
          makingCharges =
              jwVm
                  .isMakingChargesPercentage
                  .value
              ? jwVm.rawMetalPrice.value *
                    makingVal /
                    100
              : makingVal;
          double
          taxVal =
              double.tryParse(
                jwVm.taxController.text,
              ) ??
              0.0;
          double
          taxAmount =
              (jwVm.rawMetalPrice.value +
                  makingCharges) *
              taxVal /
              100;

          return Container(
            padding:
                EdgeInsets.all(
                  18.w,
                ),
            decoration: BoxDecoration(
              color:
                  AppColors.cardBackground,
              border: Border.all(
                color:
                    AppColors.cardBorder,
                width:
                    1.2,
              ),
              borderRadius: BorderRadius.circular(
                22,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(
                      width: 6.w,
                    ),
                    Text(
                      'ESTIMATE BREAKDOWN',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.h,
                ),
                _buildBreakdownRow(
                  'Pure Gold Value',
                  jwVm.formatCurrency(
                    jwVm.rawMetalPrice.value,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                _buildBreakdownRow(
                  'Making Charges',
                  jwVm.formatCurrency(
                    makingCharges <
                            0
                        ? 0
                        : makingCharges,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                _buildBreakdownRow(
                  'Estimated Tax ($taxVal%)',
                  jwVm.formatCurrency(
                    taxAmount <
                            0
                        ? 0
                        : taxAmount,
                  ),
                ),
                SizedBox(
                  height: 14.h,
                ),
                Divider(
                  color: AppColors.cardBorder,
                  height: 1,
                ),
                SizedBox(
                  height: 14.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      jwVm.formatCurrency(
                        jwVm.estimatedTotalPrice.value,
                      ),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        SizedBox(
          height:
              10.h,
        ),

        // Info Note
        Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Icon(
              Icons
                  .info_outline,
              size:
                  14,
              color:
                  AppColors.textMuted,
            ),
            SizedBox(
              width:
                  6.w,
            ),
            Text(
              "Rates based on today's live gold price",
              style: TextStyle(
                fontSize:
                    11.sp,
                color:
                    AppColors.textMuted,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          height:
              16.h,
        ),

        // Save Estimate Button
        Container(
          width: double
              .infinity,
          padding: EdgeInsets.symmetric(
            vertical:
                16.h,
          ),
          decoration: BoxDecoration(
            gradient:
                AppColors.goldGradient,
            borderRadius:
                BorderRadius.circular(
                  16,
                ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldGlow.withOpacity(
                  0.3,
                ),
                blurRadius:
                    12,
                offset: const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.save_alt_rounded,
                color:
                    Colors.black87,
                size:
                    18,
              ),
              SizedBox(
                width:
                    8.w,
              ),
              Text(
                'Save Estimate',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height:
              24.h,
        ),
      ],
    );
  }

  // ── Shared Helpers ──

  Widget
  _buildInputLabel(
    String label,
  ) {
    return Text(
      label,
      style: TextStyle(
        fontSize:
            10.sp,
        fontWeight:
            FontWeight
                .w800,
        color: AppColors
            .textMuted,
        letterSpacing:
            1,
      ),
    );
  }

  InputDecoration
  _inputDecoration({
    String?
    suffixText,
    Widget?
    suffixWidget,
  }) {
    return InputDecoration(
      filled: true,
      fillColor:
          AppColors
              .background,
      hintText:
          '0.00',
      hintStyle: TextStyle(
        color: AppColors
            .textMuted,
      ),
      suffixText:
          suffixText,
      suffix:
          suffixWidget,
      suffixStyle: TextStyle(
        color: AppColors
            .primary,
        fontWeight:
            FontWeight
                .w700,
      ),
      contentPadding:
          EdgeInsets.symmetric(
            horizontal:
                16.w,
            vertical:
                16.h,
          ),
      enabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(
              color:
                  AppColors.cardBorder,
            ),
        borderRadius:
            BorderRadius.circular(
              14,
            ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(
              color:
                  AppColors.primary,
            ),
        borderRadius:
            BorderRadius.circular(
              14,
            ),
      ),
    );
  }

  Widget
  _buildMetalPill(
    ConverterViewModel
    cvVm,
    String symbol,
    String name,
  ) {
    bool
    isSelected =
        cvVm
            .selectedMetal
            .value ==
        symbol;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            cvVm.selectMetal(
              symbol,
            ),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal:
                3,
          ),
          padding: EdgeInsets.symmetric(
            vertical:
                10.h,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                ? AppColors.primary
                : AppColors.cardBackground,
            border: Border.all(
              color:
                  isSelected
                  ? AppColors.primary
                  : AppColors.cardBorder,
            ),
            borderRadius:
                BorderRadius.circular(
                  10,
                ),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                fontSize:
                    12.sp,
                fontWeight:
                    FontWeight.w700,
                color:
                    isSelected
                    ? Colors.black
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget
  _buildBreakdownRow(
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize:
                13.sp,
            color: AppColors
                .textSecondary,
            fontWeight:
                FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize:
                13.sp,
            color: AppColors
                .textPrimary,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
