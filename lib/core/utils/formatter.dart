class AppFormatter {
  // Clean decimal formatting with commas: e.g. 285000 -> "285,000"
  static String formatNumber(double number, {int decimalDigits = 2}) {
    String fixed = number.toStringAsFixed(decimalDigits);
    List<String> parts = fixed.split('.');
    
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedInt = parts[0].replaceAllMapped(reg, (Match match) => '${match[1]},');
    
    if (decimalDigits == 0) {
      return formattedInt;
    }
    return '$formattedInt.${parts[1]}';
  }

  // Beautiful Currency Formatter: e.g. amount: 285400, currency: "PKR" -> "PKR 285,400"
  static String formatCurrency(double amount, String currencyCode) {
    if (currencyCode == 'PKR') {
      // PKR typically doesn't display decimals in general gold pricing contexts
      return 'PKR ${formatNumber(amount, decimalDigits: 0)}';
    } else if (currencyCode == 'INR') {
      return '₹ ${formatNumber(amount, decimalDigits: 0)}';
    } else if (currencyCode == 'AED') {
      return 'AED ${formatNumber(amount, decimalDigits: 2)}';
    } else {
      // USD default
      return '\$${formatNumber(amount, decimalDigits: 2)}';
    }
  }

  // Weight Formatter: e.g. 11.66, "Tola" -> "1.00 Tola"
  static String formatWeight(double weight, String unit) {
    return '${weight.toStringAsFixed(2)} $unit';
  }

  // Converts default base prices (usually USD per troy ounce in international markets)
  // to target currency, target unit, and target carat purity.
  // 1 Troy Ounce = 31.1034768 Grams
  // 1 Tola = 11.664 Grams (in South Asia)
  static double convertPrice({
    required double basePriceUsdPerOz,
    required double exchangeRateUsdToTarget,
    required String targetUnit,
    required double purityMultiplier, // e.g. 0.916 for 22K from 24K base
  }) {
    // 1. Get price in target currency per troy ounce
    double targetPricePerOz = basePriceUsdPerOz * exchangeRateUsdToTarget;
    
    // 2. Convert from per-ounce to per-gram
    // 1 oz = 31.1034768 grams
    double targetPricePerGram24K = targetPricePerOz / 31.1034768;
    
    // 3. Scale by carat purity
    double targetPricePerGramSelectedCarat = targetPricePerGram24K * purityMultiplier;
    
    // 4. Scale by target unit size
    if (targetUnit == 'Tola') {
      return targetPricePerGramSelectedCarat * 11.6638; // 1 tola = 11.6638 grams
    } else if (targetUnit == 'Ounce (oz)') {
      // Back to ounce but with purity accounted for
      return targetPricePerGramSelectedCarat * 31.1034768;
    } else {
      // Gram
      return targetPricePerGramSelectedCarat;
    }
  }
}
