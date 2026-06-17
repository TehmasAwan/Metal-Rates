class MetalRate {
  final String symbol;
  final String name;
  final double priceUsd;     // USD per Troy Ounce (standard international market rate)
  final double change24h;    // 24h percentage change (e.g. +1.45 or -0.80)
  final double high24h;
  final double low24h;
  final List<double> history1d;
  final List<double> history7d;
  final List<double> history30d;

  MetalRate({
    required this.symbol,
    required this.name,
    required this.priceUsd,
    required this.change24h,
    required this.high24h,
    required this.low24h,
    required this.history1d,
    required this.history7d,
    required this.history30d,
  });

  // Helper constructor for starting the app
  factory MetalRate.initial(String symbol, String name, double startPrice) {
    return MetalRate(
      symbol: symbol,
      name: name,
      priceUsd: startPrice,
      change24h: 0.0,
      high24h: startPrice,
      low24h: startPrice,
      history1d: List.filled(12, startPrice),
      history7d: List.filled(7, startPrice),
      history30d: List.filled(30, startPrice),
    );
  }

  MetalRate copyWith({
    double? priceUsd,
    double? change24h,
    double? high24h,
    double? low24h,
    List<double>? history1d,
    List<double>? history7d,
    List<double>? history30d,
  }) {
    return MetalRate(
      symbol: symbol,
      name: name,
      priceUsd: priceUsd ?? this.priceUsd,
      change24h: change24h ?? this.change24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      history1d: history1d ?? this.history1d,
      history7d: history7d ?? this.history7d,
      history30d: history30d ?? this.history30d,
    );
  }
}
