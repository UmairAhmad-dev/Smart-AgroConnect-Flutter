// lib/services/market_service.dart

import '../models/market_model.dart';

class MarketService {

  // Simulated data generation method
  Future<List<MarketDataPoint>> fetchHistoricalPrices(String commodity) async {
    // In a real application, this would be an HTTP call to a Stock/Commodity API
    List<MarketDataPoint> data = [];
    final now = DateTime.now();

    // Set different base prices for simulation
    double basePrice = 0;
    if (commodity == 'Wheat') basePrice = 500.0;
    else if (commodity == 'Rice') basePrice = 750.0;
    else if (commodity == 'Corn') basePrice = 350.0;
    else if (commodity == 'Cotton') basePrice = 1200.0;

    // Simulate 30 days of data (generating index 0 to 29)
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i)); // Dates chronologically increasing

      // Simulate price fluctuation (based on index and date factors)
      final price = basePrice + (i * 1.5) + (i % 5 * 3.0) - (date.day % 8);

      data.add(MarketDataPoint(
        date: date,
        price: double.parse(price.toStringAsFixed(2)),
        commodity: commodity,
      ));
    }
    return data;
  }
}