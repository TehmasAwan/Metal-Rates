import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../screen_utils.dart';
import '../../viewmodels/graph_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

class GraphScreen extends StatefulWidget {
  final String symbol;

  const GraphScreen({super.key, required this.symbol});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}
class _GraphScreenState extends State<GraphScreen> {
  // Zoom & Pan interactive states
  double _zoomScale = 1.0;
  double _panOffset = 0.0;
  double _baseZoomScale = 1.0;
  double _basePanOffset = 0.0;

  // Active tracking for tab change resets
  String? _lastSymbol;
  String? _lastTimeframe;

  // Touch hover indicator cursor states
  int? _hoveredIndex;

  late final GraphViewModel _graphVm;

  @override
  void initState() {
    super.initState();
    _graphVm = Get.put(GraphViewModel());
    _graphVm.setSymbol(widget.symbol);
  }

  @override
  void didUpdateWidget(covariant GraphScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      _graphVm.setSymbol(widget.symbol);
    }
  }

  String _flagForCurrency(String currency) {
    switch (currency) {
      case 'PKR': return '🇵🇰';
      case 'USD': return '🇺🇸';
      case 'INR': return '🇮🇳';
      case 'AED': return '🇦🇪';
      default: return '🌍';
    }
  }

  void _updateHover(Offset localPos, double chartWidth, int dataPointsCount) {
    if (dataPointsCount <= 1 || chartWidth <= 0) return;
    
    // Exact mapping of coordinates matching painter formula
    double dx = chartWidth / (dataPointsCount - 1);
    int index = ((localPos.dx - _panOffset) / (dx * _zoomScale)).round();
    
    setState(() {
      _hoveredIndex = index.clamp(0, dataPointsCount - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final graphVm = _graphVm;
    final SettingsViewModel settingsVm = Get.find<SettingsViewModel>();

    return Obx(() {
      final metal = graphVm.currentMetal;
      if (metal == null) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      final plotPoints = graphVm.getPlotData();
      final candles = graphVm.getCandleData();
      if (plotPoints.isEmpty || candles.isEmpty) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      // Reset zoom & pan offset when metal tab or timeframe changes
      final String currentSym = graphVm.selectedSymbol.value;
      final String currentTimeframe = graphVm.selectedTimeframe.value;
      if (_lastSymbol != currentSym || _lastTimeframe != currentTimeframe) {
        _zoomScale = 1.0;
        _panOffset = 0.0;
        _lastSymbol = currentSym;
        _lastTimeframe = currentTimeframe;
        _hoveredIndex = null;
      }

      bool isBullish = metal.change24h >= 0;
      Color accentColor;
      Gradient lineFillGradient;

      if (graphVm.selectedSymbol.value == 'XAU') {
        accentColor = AppColors.gold;
        lineFillGradient = LinearGradient(
          colors: [AppColors.gold.withOpacity(0.3), AppColors.gold.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      } else if (graphVm.selectedSymbol.value == 'XAG') {
        accentColor = AppColors.silver;
        lineFillGradient = LinearGradient(
          colors: [AppColors.silver.withOpacity(0.25), AppColors.silver.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      } else {
        accentColor = AppColors.platinum;
        lineFillGradient = LinearGradient(
          colors: [AppColors.platinum.withOpacity(0.2), AppColors.platinum.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      }

      return Scaffold(
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
                        if (Navigator.canPop(context))
                          GestureDetector(
                            onTap: () => Navigator.maybePop(context),
                            child: Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                          )
                        else
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
                    Container(
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
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // ── Price History Title ──
                Text(
                  'Price History',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      graphVm.formatValue(plotPoints.last),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isBullish ? AppColors.bullish : AppColors.bearish).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.show_chart_rounded, size: 12,
                            color: isBullish ? AppColors.bullish : AppColors.bearish,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${isBullish ? "+" : ""}${metal.change24h.toStringAsFixed(1)}%',
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
                SizedBox(height: 20.h),

                // ── Metal Selector Tabs ──
                Row(
                  children: ['XAU', 'XAG', 'XPT'].map((s) {
                    bool isSelected = graphVm.selectedSymbol.value == s;
                    String label = s == 'XAU' ? 'Gold' : s == 'XAG' ? 'Silver' : 'Platinum';
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () => graphVm.setSymbol(s),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.cardBackground : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.cardBorder : AppColors.cardBorder.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 14.h),

                // ── Timeframe Tabs ──
                Row(
                  children: ['1D', '7D', '30D'].map((tf) {
                    bool isSelected = graphVm.selectedTimeframe.value == tf;
                    String label = tf == '1D' ? 'Today' : tf == '7D' ? '7 Days' : '30 Days';
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: GestureDetector(
                        onTap: () => graphVm.setTimeframe(tf),
                        child: Column(
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              width: 24,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),

                // ── Chart Container ──
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MARKET PERFORMANCE',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          // Toggle Chart Type Button (Candlestick vs Line)
                          GestureDetector(
                            onTap: () => graphVm.toggleChartType(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                border: Border.all(color: AppColors.cardBorder, width: 1.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    graphVm.chartType.value == 'candlestick'
                                        ? Icons.show_chart_rounded
                                        : Icons.align_horizontal_left_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    graphVm.chartType.value == 'candlestick' ? 'Line View' : 'Candles',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // ── Seeded OHLC Premium Bar (TradingView Styled) ──
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Row(
                          children: [
                            _buildOhlcLabel('O', graphVm.formatValue(
                              _hoveredIndex != null && _hoveredIndex! < candles.length
                                  ? candles[_hoveredIndex!].open
                                  : candles.last.open
                            )),
                            const SizedBox(width: 8),
                            _buildOhlcLabel('H', graphVm.formatValue(
                              _hoveredIndex != null && _hoveredIndex! < candles.length
                                  ? candles[_hoveredIndex!].high
                                  : candles.last.high
                            )),
                            const SizedBox(width: 8),
                            _buildOhlcLabel('L', graphVm.formatValue(
                              _hoveredIndex != null && _hoveredIndex! < candles.length
                                  ? candles[_hoveredIndex!].low
                                  : candles.last.low
                            )),
                            const SizedBox(width: 8),
                            _buildOhlcLabel('C', graphVm.formatValue(
                              _hoveredIndex != null && _hoveredIndex! < candles.length
                                  ? candles[_hoveredIndex!].close
                                  : candles.last.close
                            )),
                            const SizedBox(width: 12),
                            Builder(
                              builder: (context) {
                                final currentCandle = _hoveredIndex != null && _hoveredIndex! < candles.length
                                    ? candles[_hoveredIndex!]
                                    : candles.last;
                                double change = currentCandle.close - currentCandle.open;
                                double pct = currentCandle.open != 0 ? (change / currentCandle.open) * 100 : 0.0;
                                return Text(
                                  '${change >= 0 ? "+" : ""}${change.toStringAsFixed(1)} (${change >= 0 ? "+" : ""}${pct.toStringAsFixed(2)}%)',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: change >= 0 ? AppColors.bullish : AppColors.bearish,
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 12.h),

                      // ── Interactive CustomPaint Chart ──
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double chartWidth = max(0.0, constraints.maxWidth - InteractiveFinancialChartPainter.yAxisWidth);
                          return Stack(
                            children: [
                              GestureDetector(
                                // Pinch-to-zoom gestures
                                onScaleStart: (details) {
                                  _baseZoomScale = _zoomScale;
                                  _basePanOffset = _panOffset;
                                },
                                onScaleUpdate: (details) {
                                  setState(() {
                                    if (details.pointerCount == 2) {
                                      _zoomScale = (_baseZoomScale * details.horizontalScale).clamp(1.0, 10.0);
                                      _panOffset = _panOffset.clamp(chartWidth * (1.0 - _zoomScale), 0.0);
                                    } else if (details.pointerCount == 1) {
                                      _panOffset = (_basePanOffset + details.focalPointDelta.dx)
                                          .clamp(chartWidth * (1.0 - _zoomScale), 0.0);
                                    }
                                  });
                                },
                                // Touch selection hover cursor details
                                onLongPressStart: (details) => _updateHover(details.localPosition, chartWidth, candles.length),
                                onLongPressMoveUpdate: (details) => _updateHover(details.localPosition, chartWidth, candles.length),
                                onLongPressEnd: (_) => setState(() => _hoveredIndex = null),
                                onTapDown: (details) => _updateHover(details.localPosition, chartWidth, candles.length),
                                onTapUp: (_) => setState(() => _hoveredIndex = null),
                                child: SizedBox(
                                  height: 220.h,
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: InteractiveFinancialChartPainter(
                                      candles: candles,
                                      chartType: graphVm.chartType.value,
                                      zoomScale: _zoomScale,
                                      panOffset: _panOffset,
                                      lineColor: accentColor,
                                      fillGradient: lineFillGradient,
                                      hoveredIndex: _hoveredIndex,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Zoom +/- Float Overlay Control buttons
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _zoomScale = (_zoomScale * 1.25).clamp(1.0, 10.0);
                                          _panOffset = _panOffset.clamp(chartWidth * (1.0 - _zoomScale), 0.0);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: AppColors.background.withOpacity(0.85),
                                          border: Border.all(color: AppColors.cardBorder),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.add, color: AppColors.textPrimary, size: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _zoomScale = (_zoomScale / 1.25).clamp(1.0, 10.0);
                                          if (_zoomScale <= 1.0) {
                                            _panOffset = 0.0;
                                          } else {
                                            _panOffset = _panOffset.clamp(chartWidth * (1.0 - _zoomScale), 0.0);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: AppColors.background.withOpacity(0.85),
                                          border: Border.all(color: AppColors.cardBorder),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.remove, color: AppColors.textPrimary, size: 16),
                                      ),
                                    ),
                                    if (_zoomScale > 1.0) ...[
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _zoomScale = 1.0;
                                            _panOffset = 0.0;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.background.withOpacity(0.85),
                                            border: Border.all(color: AppColors.cardBorder),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Reset Zoom',
                                            style: TextStyle(
                                              fontSize: 9.sp,
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Statistics Cards ──
                _buildStatCard(
                  'Highest Price',
                  graphVm.formatValue(graphVm.getMaxVal()),
                  AppColors.textPrimary,
                ),
                SizedBox(height: 10.h),
                _buildStatCard(
                  'Lowest Price',
                  graphVm.formatValue(graphVm.getMinVal()),
                  AppColors.textPrimary,
                ),
                SizedBox(height: 10.h),
                _buildStatCard(
                  'Price Change',
                  plotPoints.length >= 2
                    ? '${(plotPoints.last - plotPoints.first) >= 0 ? "+" : ""}${graphVm.formatValue((plotPoints.last - plotPoints.first).abs())}'
                    : graphVm.formatValue(0),
                  (plotPoints.length >= 2 && (plotPoints.last - plotPoints.first) >= 0)
                    ? AppColors.bullish
                    : AppColors.bearish,
                ),
                SizedBox(height: 24.h),

                // ── Expert Market Insights Banner ──
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.12),
                        AppColors.cardBackground,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expert Market Insights',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Receive weekly gold market analysis for the Karachi Stock Exchange directly in your inbox.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
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
      );
    });
  }

  Widget _buildOhlcLabel(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Interactive Financial Candlestick / Line Chart Painter
// ────────────────────────────────────────────────
class InteractiveFinancialChartPainter extends CustomPainter {
  final List<CandleData> candles;
  final String chartType; // 'candlestick' or 'line'
  final double zoomScale;
  final double panOffset;
  final Color lineColor;
  final Gradient fillGradient;
  final int? hoveredIndex;

  static const double yAxisWidth = 62.0;
  static const double xAxisHeight = 22.0;

  InteractiveFinancialChartPainter({
    required this.candles,
    required this.chartType,
    required this.zoomScale,
    required this.panOffset,
    required this.lineColor,
    required this.fillGradient,
    required this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    double chartWidth = size.width - yAxisWidth;
    double chartHeight = size.height - xAxisHeight;

    double dx = chartWidth / (candles.length - 1);

    // Calculate maximum and minimum values to scale Y-axis correctly
    double maxVal = candles.map((c) => chartType == 'candlestick' ? c.high : c.close).reduce(max);
    double minVal = candles.map((c) => chartType == 'candlestick' ? c.low : c.close).reduce(min);
    double diff = maxVal - minVal;
    if (diff == 0) diff = 1.0;

    double padTop = chartHeight * 0.12;
    double padBottom = chartHeight * 0.12;
    double usableHeight = chartHeight - padTop - padBottom;

    double getY(double price) {
      return chartHeight - padBottom - ((price - minVal) / diff * usableHeight);
    }

    double getX(int index) {
      return (index * dx) * zoomScale + panOffset;
    }

    // 1. Draw Grid Lines and Y-axis text
    Paint gridPaint = Paint()
      ..color = AppColors.cardBorder.withOpacity(0.3)
      ..strokeWidth = 0.8;

    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    int gridLines = 4;
    for (int i = 0; i < gridLines; i++) {
      double fraction = i / (gridLines - 1);
      double price = minVal + fraction * diff;
      double y = getY(price);

      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      textPainter.text = TextSpan(
        text: price.toStringAsFixed(1),
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 9.0,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(chartWidth + 6, y - 5));
    }

    // 2. Draw Candlesticks or Line Chart
    if (chartType == 'candlestick') {
      Paint wickPaint = Paint()..strokeWidth = 1.2;
      Paint bodyPaint = Paint()..style = PaintingStyle.fill;
      double baseCandleWidth = dx * zoomScale * 0.7;
      double candleWidth = baseCandleWidth.clamp(2.5, 30.0);

      for (int i = 0; i < candles.length; i++) {
        final c = candles[i];
        double cx = getX(i);

        // Clip boundary optimization
        if (cx < -20 || cx > chartWidth + 20) continue;

        bool isBullish = c.close >= c.open;
        Color candleColor = isBullish ? AppColors.bullish : AppColors.bearish;
        wickPaint.color = candleColor;
        bodyPaint.color = candleColor;

        double yOpen = getY(c.open);
        double yClose = getY(c.close);
        double yHigh = getY(c.high);
        double yLow = getY(c.low);

        // Draw wicks
        canvas.drawLine(Offset(cx, yHigh), Offset(cx, yLow), wickPaint);

        // Draw body rectangle
        double top = min(yOpen, yClose);
        double bottom = max(yOpen, yClose);
        double bodyH = (bottom - top).clamp(1.0, 999.0);

        canvas.drawRect(
          Rect.fromLTWH(cx - candleWidth / 2, top, candleWidth, bodyH),
          bodyPaint,
        );

        // Draw semi-transparent Volume bar at the bottom of the chart
        double volFactor = (c.high - c.low) / diff;
        double volHeight = (volFactor * (chartHeight * 0.16)).clamp(3.0, chartHeight * 0.16);
        Paint volPaint = Paint()
          ..color = candleColor.withOpacity(0.12)
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromLTWH(cx - candleWidth / 2, chartHeight - volHeight, candleWidth, volHeight),
          volPaint,
        );
      }
    } else {
      // Draw smooth line & gradient fill
      Path linePath = Path();
      Path fillPath = Path();
      bool hasStarted = false;

      for (int i = 0; i < candles.length; i++) {
        double cx = getX(i);
        double cy = getY(candles[i].close);

        if (!hasStarted) {
          linePath.moveTo(cx, cy);
          fillPath.moveTo(cx, chartHeight);
          fillPath.lineTo(cx, cy);
          hasStarted = true;
        } else {
          double prevX = getX(i - 1);
          double prevY = getY(candles[i - 1].close);
          double cx1 = prevX + (cx - prevX) / 2;
          double cy1 = prevY;
          double cx2 = prevX + (cx - prevX) / 2;
          double cy2 = cy;

          linePath.cubicTo(cx1, cy1, cx2, cy2, cx, cy);
          fillPath.cubicTo(cx1, cy1, cx2, cy2, cx, cy);
        }
      }

      if (hasStarted) {
        fillPath.lineTo(getX(candles.length - 1), chartHeight);
        fillPath.close();

        Paint fillPaint = Paint()
          ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight));
        canvas.drawPath(fillPath, fillPaint);

        Paint linePaint = Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(linePath, linePaint);
      }
    }

    // 3. Draw X-axis timeline labels
    int labelStep = (candles.length / 5).ceil().clamp(1, 99);
    for (int i = 0; i < candles.length; i += labelStep) {
      double cx = getX(i);
      if (cx < 10 || cx > chartWidth - 10) continue;

      textPainter.text = TextSpan(
        text: candles[i].date,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 9.0,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx - textPainter.width / 2, chartHeight + 4));
    }

    // 4. Draw current horizontal price tracker line & tag
    double latestPrice = candles.last.close;
    double latestY = getY(latestPrice);
    if (latestY >= 0 && latestY <= chartHeight) {
      Paint trackerPaint = Paint()
        ..color = AppColors.bullish.withOpacity(0.5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      double dashW = 4.0;
      double dashS = 4.0;
      double curX = 0.0;
      while (curX < chartWidth) {
        canvas.drawLine(Offset(curX, latestY), Offset(curX + dashW, latestY), trackerPaint);
        curX += dashW + dashS;
      }

      Paint tagBgPaint = Paint()
        ..color = AppColors.bullish
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(chartWidth + 2, latestY - 8, yAxisWidth - 4, 16),
          const Radius.circular(4),
        ),
        tagBgPaint,
      );

      textPainter.text = TextSpan(
        text: latestPrice.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 9.0,
          fontWeight: FontWeight.w900,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(chartWidth + 6, latestY - 5));
    }

    // 5. Draw touch hover details vertical guidance line and dots
    if (hoveredIndex != null && hoveredIndex! >= 0 && hoveredIndex! < candles.length) {
      final selectedCandle = candles[hoveredIndex!];
      double hx = getX(hoveredIndex!);
      double hy = getY(selectedCandle.close);

      if (hx >= 0 && hx <= chartWidth) {
        Paint tooltipLinePaint = Paint()
          ..color = AppColors.primary.withOpacity(0.4)
          ..strokeWidth = 1.0;

        double startY = 0.0;
        while (startY < chartHeight) {
          canvas.drawLine(Offset(hx, startY), Offset(hx, startY + 4.0), tooltipLinePaint);
          startY += 8.0;
        }

        Paint pulseOuter = Paint()
          ..color = lineColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        Paint pulseInner = Paint()
          ..color = lineColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(hx, hy), 8.0, pulseOuter);
        canvas.drawCircle(Offset(hx, hy), 4.0, pulseInner);
      }
    }
  }

  @override
  bool shouldRepaint(covariant InteractiveFinancialChartPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.chartType != chartType ||
        oldDelegate.zoomScale != zoomScale ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
