import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../screen_utils.dart';
import '../../viewmodels/zakat_viewmodel.dart';

class ZakatScreen extends StatelessWidget {
  const ZakatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ZakatViewModel zkVm = Get.put(ZakatViewModel());

    return Obx(() => Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Banner
              Text(
                'Zakat Calculator',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Evaluate obligational Zakat (2.5%) based on live rates',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),

              // Educational Nisab Note
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zakat Nisab Reference',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.zakatInfoText,
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gold: 7.5 Tolas (87.48g)',
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Silver: 52.5 Tolas (612.36g)',
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Input Sheets
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Unit selector row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weight Unit',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(() => Row(
                          children: ['Gram (g)', 'Tola'].map((u) {
                            bool isSel = zkVm.activeWeightUnit.value == u;
                            return GestureDetector(
                              onTap: () => zkVm.toggleWeightUnit(u),
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.primary : AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSel ? AppColors.primary : AppColors.cardBorder),
                                ),
                                child: Text(
                                  u,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? Colors.black : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                      ],
                    ),
                    Divider(color: AppColors.cardBorder, height: 24),

                    // Inputs list
                    _buildInputField('Gold Owned', zkVm.goldWeightController, zkVm),
                    SizedBox(height: 12.h),
                    _buildInputField('Silver Owned', zkVm.silverWeightController, zkVm),
                    SizedBox(height: 12.h),
                    _buildCashInputField('Cash & Savings', zkVm.cashController, zkVm),
                    SizedBox(height: 12.h),
                    _buildCashInputField('Other Invested Assets', zkVm.investmentsController, zkVm),
                    SizedBox(height: 12.h),
                    _buildCashInputField('Liabilities & Debts (-)', zkVm.liabilitiesController, zkVm),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Nisab Threshold Choice
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nisab Base Standard',
                    style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                  ),
                  Obx(() => Row(
                    children: ['Silver', 'Gold'].map((t) {
                      bool isSel = zkVm.activeNisabThresholdType.value == t;
                      return GestureDetector(
                        onTap: () => zkVm.toggleNisabType(t),
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.accent : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSel ? AppColors.accent : AppColors.cardBorder),
                          ),
                          child: Text(
                            '$t Base',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.black : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                ],
              ),
              SizedBox(height: 24.h),

              // Obx Result Sheet Card
              Obx(() {
                final res = zkVm.result.value;
                return Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: res.isEligible ? AppColors.bullish.withOpacity(0.04) : AppColors.cardBackground,
                    border: Border.all(
                      color: res.isEligible ? AppColors.bullish.withOpacity(0.3) : AppColors.cardBorder,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ZAKAT STATUS',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                res.isEligible ? 'Zakat is Obligatory' : 'Below Nisab Limit',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                  color: res.isEligible ? AppColors.bullish : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            res.isEligible ? Icons.verified_user : Icons.remove_moderator,
                            color: res.isEligible ? AppColors.bullish : AppColors.textMuted,
                            size: 28,
                          ),
                        ],
                      ),
                      Divider(color: AppColors.cardBorder, height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Net Taxable Wealth:',
                            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                          ),
                          Text(
                            zkVm.formatCurrency(res.netWealth),
                            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nisab Limit (${res.nisabType}):',
                            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                          ),
                          Text(
                            zkVm.formatCurrency(res.nisabThreshold),
                            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL ZAKAT DUE (2.5%)',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              zkVm.formatCurrency(res.zakatAmount),
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w900,
                                color: res.isEligible ? AppColors.bullish : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildInputField(String label, TextEditingController ctrl, ZakatViewModel zkVm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (${zkVm.activeWeightUnit.value})',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (_) => zkVm.calculate(),
        ),
      ],
    );
  }

  Widget _buildCashInputField(String label, TextEditingController ctrl, ZakatViewModel zkVm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (${zkVm.formatCurrency(0).split(' ')[0]})',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (_) => zkVm.calculate(),
        ),
      ],
    );
  }
}
