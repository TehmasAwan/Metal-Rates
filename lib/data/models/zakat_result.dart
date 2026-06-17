class ZakatResult {
  final double goldGrams;
  final double goldValue;
  final double silverGrams;
  final double silverValue;
  final double cashAmount;
  final double otherAssets;
  final double liabilities;
  final double netWealth;
  final double nisabThreshold;
  final bool isEligible;
  final double zakatAmount;
  final String nisabType;

  ZakatResult({
    required this.goldGrams,
    required this.goldValue,
    required this.silverGrams,
    required this.silverValue,
    required this.cashAmount,
    required this.otherAssets,
    required this.liabilities,
    required this.netWealth,
    required this.nisabThreshold,
    required this.isEligible,
    required this.zakatAmount,
    required this.nisabType,
  });

  factory ZakatResult.empty() {
    return ZakatResult(
      goldGrams: 0.0,
      goldValue: 0.0,
      silverGrams: 0.0,
      silverValue: 0.0,
      cashAmount: 0.0,
      otherAssets: 0.0,
      liabilities: 0.0,
      netWealth: 0.0,
      nisabThreshold: 0.0,
      isEligible: false,
      zakatAmount: 0.0,
      nisabType: 'Silver',
    );
  }
}
