import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../screen_utils.dart';

class MetalCard extends StatelessWidget {
  final String symbol;
  final String name;
  final String formattedPrice;
  final double change24h;
  final String highPrice;
  final String lowPrice;
  final VoidCallback onTap;

  const MetalCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.formattedPrice,
    required this.change24h,
    required this.highPrice,
    required this.lowPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isBullish = change24h >= 0;

    // Choose specific color theme for Gold vs Silver vs Platinum
    Color metalPrimaryColor;
    Gradient metalGradient;
    Color glowColor;
    String shortcut;
    IconData metalIcon;

    if (symbol == 'XAU') {
      metalPrimaryColor = AppColors.gold;
      metalGradient = AppColors.goldGradient;
      glowColor = AppColors.goldGlow.withOpacity(0.12);
      shortcut = 'Au';
      metalIcon = Icons.monetization_on_outlined;
    } else if (symbol == 'XAG') {
      metalPrimaryColor = AppColors.silver;
      metalGradient = AppColors.silverGradient;
      glowColor = AppColors.silverGlow.withOpacity(0.09);
      shortcut = 'Ag';
      metalIcon = Icons.diamond_outlined;
    } else {
      metalPrimaryColor = AppColors.platinum;
      metalGradient = AppColors.platinumGradient;
      glowColor = AppColors.platinumGlow.withOpacity(0.07);
      shortcut = 'Pt';
      metalIcon = Icons.eco_outlined;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: AppColors.primary.withOpacity(0.05),
          highlightColor: AppColors.primary.withOpacity(0.03),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metal label
                    Text(
                      name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.4,
                      ),
                    ),
                    // Trend badge pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (isBullish ? AppColors.bullish : AppColors.bearish).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isBullish ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            size: 11,
                            color: isBullish ? AppColors.bullish : AppColors.bearish,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${isBullish ? "+" : ""}${change24h.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: isBullish ? AppColors.bullish : AppColors.bearish,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Element avatar circle
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        gradient: metalGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: metalPrimaryColor.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(metalIcon, color: Colors.black87, size: 22),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedPrice,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'per 10g',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(color: AppColors.cardBorder, thickness: 0.8),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_down_rounded, size: 14, color: AppColors.bearish),
                        const SizedBox(width: 4),
                        Text(
                          'Low: $lowPrice',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.trending_up_rounded, size: 14, color: AppColors.bullish),
                        const SizedBox(width: 4),
                        Text(
                          'High: $highPrice',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
