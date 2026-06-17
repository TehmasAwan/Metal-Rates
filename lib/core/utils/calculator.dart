import '../../data/models/zakat_result.dart';

class AppCalculator {
  // 1. Zakat Calculator
  // Rules:
  // - Gold Nisab = 87.48 grams (7.5 tola)
  // - Silver Nisab = 612.36 grams (52.5 tola)
  // - Zakat is due if net asset value exceeds the Nisab threshold.
  // - Traditional consensus: Nisab threshold for liquid cash/mix wealth is set to the Silver Nisab value
  //   because it is lower and triggers Zakat at a lower wealth, helping more needy people.
  // - Zakat rate = 2.5% of total assets.
  static ZakatResult calculateZakat({
    required double goldGrams,
    required double goldPricePerGram,
    required double silverGrams,
    required double silverPricePerGram,
    required double cashAmount,
    required double otherAssets,
    required double liabilities,
    required String nisabType, // "Gold" or "Silver"
  }) {
    double goldValue = goldGrams * goldPricePerGram;
    double silverValue = silverGrams * silverPricePerGram;
    double totalAssets = goldValue + silverValue + cashAmount + otherAssets;
    double netWealth = totalAssets - liabilities;
    if (netWealth < 0) netWealth = 0;

    // Define Nisab in cash equivalents
    double goldNisabValue = 87.48 * goldPricePerGram;
    double silverNisabValue = 612.36 * silverPricePerGram;
    double selectedNisabThreshold = (nisabType == 'Gold') ? goldNisabValue : silverNisabValue;

    bool isEligible = netWealth >= selectedNisabThreshold;
    double zakatDue = isEligible ? netWealth * 0.025 : 0.0;

    return ZakatResult(
      goldGrams: goldGrams,
      goldValue: goldValue,
      silverGrams: silverGrams,
      silverValue: silverValue,
      cashAmount: cashAmount,
      otherAssets: otherAssets,
      liabilities: liabilities,
      netWealth: netWealth,
      nisabThreshold: selectedNisabThreshold,
      isEligible: isEligible,
      zakatAmount: zakatDue,
      nisabType: nisabType,
    );
  }

  // 2. Jewellery Estimator Calculator
  // Formula: Final Price = (Metal Rate of Carat * Weight) + Making Charges + Tax
  static double calculateJewelleryPrice({
    required double basePricePerGram24K,
    required double weight,
    required String carat,
    required double makingChargesValue,
    required bool isMakingChargesPercentage, // true: % of gold value, false: fixed flat fee
    required double taxPercentage,
  }) {
    // Carat multiplier
    double purity = 1.0;
    switch (carat) {
      case '22K':
        purity = 22 / 24; // 0.9167
        break;
      case '21K':
        purity = 21 / 24; // 0.875
        break;
      case '18K':
        purity = 18 / 24; // 0.75
        break;
      case '24K':
      default:
        purity = 1.0;
        break;
    }

    double metalPricePerGram = basePricePerGram24K * purity;
    double rawMetalValue = metalPricePerGram * weight;

    // Calculate making charges
    double makingCharges = isMakingChargesPercentage
        ? (rawMetalValue * (makingChargesValue / 100))
        : makingChargesValue;

    double valueBeforeTax = rawMetalValue + makingCharges;

    // Calculate Tax / VAT
    double tax = valueBeforeTax * (taxPercentage / 100);

    return valueBeforeTax + tax;
  }
}
