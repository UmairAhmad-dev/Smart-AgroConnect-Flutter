// lib/models/market_model.dart

import 'package:fl_chart/fl_chart.dart';

class MarketDataPoint {
  final DateTime date;
  final double price;
  final String commodity;

  MarketDataPoint({
    required this.date,
    required this.price,
    required this.commodity,
  });

  // Used for converting to FLSpot for charting (X=index, Y=price)
  FlSpot toFlSpot(int index) {
    return FlSpot(index.toDouble(), price);
  }
}