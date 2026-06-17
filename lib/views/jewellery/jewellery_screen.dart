import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../screen_utils.dart';
import '../../viewmodels/jewellery_viewmodel.dart';

class JewelleryScreen
    extends
        StatelessWidget {
  const JewelleryScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext
    context,
  ) {
    final JewelleryViewModel
    jwVm = Get.put(
      JewelleryViewModel(),
    );

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
                // Title Header
                Text(
                  'Jewellery Estimator',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Calculate final jewelry price with making charges & tax',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),

                // Form Container
                Container(
                  padding: EdgeInsets.all(
                    20.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(
                      color: AppColors.cardBorder,
                    ),
                    borderRadius: BorderRadius.circular(
                      24,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Weight Input
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jewellery Weight',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Unit Toggle (Gram vs Tola)
                          Obx(
                            () => Row(
                              children:
                                  [
                                    'Gram (g)',
                                    'Tola',
                                  ].map(
                                    (
                                      u,
                                    ) {
                                      bool isSel =
                                          jwVm.selectedWeightUnit.value ==
                                          u;
                                      return GestureDetector(
                                        onTap: () => jwVm.toggleWeightUnit(
                                          u,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 6,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSel
                                                ? AppColors.primary
                                                : AppColors.background,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            u,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: isSel
                                                  ? Colors.black
                                                  : AppColors.textSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      TextField(
                        controller: jwVm.weightController,
                        inputFormatters: const [],

                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.cardBorder,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primary,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        onChanged:
                            (
                              _,
                            ) => jwVm.calculate(),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),

                      // Carat Purity Selector
                      Text(
                        'Gold Purity (Carat)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      horizontal: 4,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? AppColors.primary
                                          : AppColors.background,
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                      border: Border.all(
                                        color: isSel
                                            ? AppColors.primary
                                            : AppColors.cardBorder,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        carat,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
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
                        height: 20.h,
                      ),

                      // Making Charges Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Making Charges',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Obx(
                            () => Row(
                              children: [
                                GestureDetector(
                                  onTap: () => jwVm.toggleMakingChargesType(
                                    true,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: jwVm.isMakingChargesPercentage.value
                                          ? AppColors.primary
                                          : AppColors.background,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                          6,
                                        ),
                                        bottomLeft: Radius.circular(
                                          6,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Percentage (%)',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: jwVm.isMakingChargesPercentage.value
                                            ? Colors.black
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => jwVm.toggleMakingChargesType(
                                    false,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !jwVm.isMakingChargesPercentage.value
                                          ? AppColors.primary
                                          : AppColors.background,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(
                                          6,
                                        ),
                                        bottomRight: Radius.circular(
                                          6,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Flat Cash',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: !jwVm.isMakingChargesPercentage.value
                                            ? Colors.black
                                            : AppColors.textSecondary,
                                      ),
                                    ),
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
                      TextField(
                        controller: jwVm.makingChargesController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          suffixText: jwVm.isMakingChargesPercentage.value
                              ? '%'
                              : jwVm
                                    .formatCurrency(
                                      0,
                                    )
                                    .split(
                                      ' ',
                                    )[0],
                          suffixStyle: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.cardBorder,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primary,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        onChanged:
                            (
                              _,
                            ) => jwVm.calculate(),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),

                      // Tax Selector
                      Text(
                        'VAT / Applied Government Taxes (%)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      TextField(
                        controller: jwVm.taxController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          suffixText: '%',
                          suffixStyle: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.cardBorder,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primary,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        onChanged:
                            (
                              _,
                            ) => jwVm.calculate(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),

                // Final Pricing Outcome Card
                Obx(
                  () => Container(
                    padding: EdgeInsets.all(
                      20.w,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(
                            0.04,
                          ),
                          AppColors.cardBackground,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(
                          0.3,
                        ),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        24,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildCostRow(
                          'Raw Gold Material Price:',
                          jwVm.rawMetalPrice.value,
                          jwVm,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Obx(
                          () {
                            final double weightInput =
                                double.tryParse(
                                  jwVm.weightController.text,
                                ) ??
                                0.0;
                            final double makingVal =
                                double.tryParse(
                                  jwVm.makingChargesController.text,
                                ) ??
                                0.0;
                            final double taxPercent =
                                double.tryParse(
                                  jwVm.taxController.text,
                                ) ??
                                0.0;

                            // Recompute breakdown based on the same inputs used in viewmodel
                            final double raw = jwVm.rawMetalPrice.value;
                            final double makingCharges = jwVm.isMakingChargesPercentage.value
                                ? raw *
                                      makingVal /
                                      100
                                : makingVal;
                            final double valueBeforeTax =
                                raw +
                                makingCharges;
                            final double taxAmount =
                                valueBeforeTax *
                                taxPercent /
                                100;

                            return Column(
                              children: [
                                _buildCostRow(
                                  'Making Charges Added:',
                                  makingCharges,
                                  jwVm,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                _buildCostRow(
                                  'Estimated VAT/Taxes:',
                                  taxAmount,
                                  jwVm,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            );
                          },
                        ),

                        Divider(
                          color: AppColors.cardBorder,
                          height: 24,
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(
                            12.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(
                              16,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ESTIMATED FINAL COST',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                jwVm.formatCurrency(
                                  jwVm.estimatedTotalPrice.value,
                                ),
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
  _buildCostRow(
    String title,
    double value,
    JewelleryViewModel
    jwVm,
  ) {
    double
    cleanVal =
        value < 0
        ? 0
        : value;
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors
                .textSecondary,
            fontSize:
                12.sp,
            fontWeight:
                FontWeight.w500,
          ),
        ),
        Text(
          jwVm.formatCurrency(
            cleanVal,
          ),
          style: TextStyle(
            color: AppColors
                .textPrimary,
            fontSize:
                13.sp,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
