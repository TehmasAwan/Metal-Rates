import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../screen_utils.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../core/utils/formatter.dart';
import '../../data/services/api_service.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _flagForCurrency(String currency) {
    switch (currency) {
      case 'PKR': return '🇵🇰';
      case 'USD': return '🇺🇸';
      case 'INR': return '🇮🇳';
      case 'AED': return '🇦🇪';
      default: return '🌍';
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsViewModel settingsVm = Get.find<SettingsViewModel>();

    return Obx(() => Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App Bar Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu, color: AppColors.textPrimary, size: 22),
                      SizedBox(width: 12.w),
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
                  Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      borderRadius: BorderRadius.circular(14),
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
                        const SizedBox(width: 5),
                        Text(
                          _flagForCurrency(settingsVm.selectedCurrency.value),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              SizedBox(height: 20.h),

              // ── Page Title ──
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 24.h),

              // ══════════════════════════════════════════
              // PREFERENCES SECTION
              // ══════════════════════════════════════════
              _buildSectionLabel('PREFERENCES'),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    // Country & Currency
                    Obx(() => _buildDropdownTile(
                      icon: Icons.public_rounded,
                      label: 'Country & Currency',
                      value: '${settingsVm.selectedCountry.value.split(' ').first}, ${settingsVm.selectedCurrency.value}',
                      items: settingsVm.availableCountries,
                      currentValue: settingsVm.selectedCountry.value,
                      onChanged: (val) => settingsVm.updateCountry(val),
                    )),
                    Divider(color: AppColors.cardBorder, height: 1),

                    // Default Metal
                    _buildStaticTile(
                      icon: Icons.diamond_outlined,
                      label: 'Default Metal',
                      value: 'Gold',
                    ),
                    Divider(color: AppColors.cardBorder, height: 1),

                    // Default Weight Unit
                    Obx(() => _buildDropdownTile(
                      icon: Icons.balance_outlined,
                      label: 'Default Weight Unit',
                      value: settingsVm.selectedUnit.value,
                      items: settingsVm.availableUnits,
                      currentValue: settingsVm.selectedUnit.value,
                      onChanged: (val) => settingsVm.updateUnit(val),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ══════════════════════════════════════════
              // NOTIFICATIONS SECTION
              // ══════════════════════════════════════════
              _buildSectionLabel('NOTIFICATIONS'),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    Obx(() => Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price Alert',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Real-time alerts for price targets',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: settingsVm.priceAlertEnabled.value,
                          onChanged: (val) => settingsVm.togglePriceAlert(val),
                        ),
                      ],
                    )),
                    SizedBox(height: 14.h),
                    // Target Price Input
                    Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TARGET PRICE (${settingsVm.selectedCurrency.value})',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () => _showTargetPriceBottomSheet(context, settingsVm),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: Border.all(color: AppColors.cardBorder),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  settingsVm.targetPrice.value.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'SET TARGET',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ══════════════════════════════════════════
              // DISPLAY SECTION
              // ══════════════════════════════════════════
              _buildSectionLabel('DISPLAY'),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: _cardDecoration(),
                child: Obx(() => Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        settingsVm.isDarkMode.value
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            settingsVm.isDarkMode.value ? 'Dark theme active' : 'Light theme active',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: settingsVm.isDarkMode.value,
                      onChanged: (val) => settingsVm.toggleDarkMode(val),
                    ),
                  ],
                )),
              ),
              SizedBox(height: 24.h),

              // ══════════════════════════════════════════
              // ABOUT SECTION
              // ══════════════════════════════════════════
              _buildSectionLabel('ABOUT'),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildStaticTile(
                      icon: Icons.info_outline_rounded,
                      label: 'App Version',
                      value: 'v2.4.1 Premium',
                    ),
                    Divider(color: AppColors.cardBorder, height: 1),
                    _buildNavigationTile(
                      icon: Icons.star_outline_rounded,
                      label: 'Rate us',
                    ),
                    Divider(color: AppColors.cardBorder, height: 1),
                    _buildNavigationTile(
                      icon: Icons.shield_outlined,
                      label: 'Privacy Policy',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ══════════════════════════════════════════
              // PRO FEATURE BANNER
              // ══════════════════════════════════════════
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.cardBackground,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PRO FEATURE',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Historical Vault Analytics',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Access 50 years of precious metal market data with deep pattern recognition.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    ));
  }

  // ── Reusable builders ──

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.cardBackground,
      border: Border.all(color: AppColors.cardBorder, width: 1.2),
      borderRadius: BorderRadius.circular(20),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required String currentValue,
    required Function(String) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
      onTap: () {
        Get.bottomSheet(
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                ...items.map((item) => ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      color: item == currentValue ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: item == currentValue ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                  trailing: item == currentValue
                      ? Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                      : null,
                  onTap: () {
                    onChanged(item);
                    Get.back();
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaticTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String label,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      onTap: () {},
    );
  }

  void _showTargetPriceBottomSheet(BuildContext context, SettingsViewModel settingsVm) {
    final TextEditingController controller = TextEditingController(
      text: settingsVm.targetPrice.value.toStringAsFixed(2),
    );
    final apiService = Get.find<ApiService>();
    final currentGoldPrice = (apiService.rates['XAU']?.priceUsd ?? ApiService.baseGold) *
        (apiService.exchangeRates[settingsVm.selectedCurrency.value] ?? 1.0);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Set Price Alert Target',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Receive a notification when Gold crosses this price.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'CURRENT PRICE: ${AppFormatter.formatCurrency(currentGoldPrice, settingsVm.selectedCurrency.value)}',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                hintText: 'Enter target price',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
                prefixText: '${settingsVm.selectedCurrency.value} ',
                prefixStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final val = double.tryParse(controller.text);
                      if (val != null && val > 0) {
                        settingsVm.updateTargetPrice(val);
                        Get.back();
                      } else {
                        Get.snackbar(
                          'Invalid Price',
                          'Please enter a valid positive number.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.9),
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Save Target',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
