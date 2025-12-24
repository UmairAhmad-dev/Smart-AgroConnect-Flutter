// lib/views/home/market_analysis_screen.dart (Final Professional UI)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../services/market_service.dart';
import '../../models/market_model.dart';

// Reusing constants
abstract class AppSpacing {
  static const double xsmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryBlue = Color(0xFF42A5F5);
  static const Color accentYellow = Color(0xFFFFCC00);
}


class MarketAnalysisScreen extends StatefulWidget {
  const MarketAnalysisScreen({super.key});

  @override
  State<MarketAnalysisScreen> createState() => _MarketAnalysisScreenState();
}

class _MarketAnalysisScreenState extends State<MarketAnalysisScreen> {
  final MarketService _service = MarketService();
  String _selectedCommodity = 'Wheat';

  // List of commodities for the dropdown filter
  final List<String> _commodities = ['Wheat', 'Rice', 'Corn', 'Cotton'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('Commodity Price Analysis', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: SizedBox(
          width: 1000,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. Filter Dropdown ---
                _buildCommodityFilter(),
                const SizedBox(height: AppSpacing.large),

                // --- 2. Chart Card (Uses FutureBuilder) ---
                _buildPriceChartCard(),
                const SizedBox(height: AppSpacing.large),

                // --- 3. Price Summary ---
                _buildSummaryCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommodityFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium, vertical: AppSpacing.xsmall),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCommodity,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkGreen),
          style: GoogleFonts.montserrat(fontSize: 16, color: AppColors.darkGreen, fontWeight: FontWeight.w600),
          items: _commodities.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCommodity = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPriceChartCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '30-Day Price Trend for $_selectedCommodity (Rs/Quintal)',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
            ),
            const SizedBox(height: AppSpacing.medium),
            SizedBox(
              height: 350,
              // FutureBuilder loads the data for the chart dynamically
              child: FutureBuilder<List<MarketDataPoint>>(
                future: _service.fetchHistoricalPrices(_selectedCommodity),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading data: ${snapshot.error}'));
                  }
                  final data = snapshot.data ?? [];
                  if (data.isEmpty) {
                    return const Center(child: Text('No historical data available.'));
                  }

                  // Find min/max price for Y-axis scaling
                  final prices = data.map((d) => d.price).toList();
                  final minPrice = prices.reduce((a, b) => a < b ? a : b);
                  final maxPrice = prices.reduce((a, b) => a > b ? a : b);
                  final yMin = (minPrice - 10).floorToDouble();
                  final yMax = (maxPrice + 10).ceilToDouble();

                  // Convert data points to FlSpot objects for the chart
                  final spots = data.asMap().entries.map((entry) {
                    return entry.value.toFlSpot(entry.key);
                  }).toList();

                  return LineChart(
                    LineChartData(
                      minY: yMin,
                      maxY: yMax,
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 7, // Label every 7th day
                            getTitlesWidget: (value, meta) {
                              if (value < data.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8.0,
                                  child: Text(DateFormat('MMM d').format(data[value.toInt()].date), style: GoogleFonts.roboto(fontSize: 10)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0), style: GoogleFonts.roboto(fontSize: 10)),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.primaryBlue,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [AppColors.primaryBlue.withOpacity(0.3), AppColors.primaryBlue.withOpacity(0.0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    // This widget uses a FutureBuilder to calculate the summary stats from the service data
    return FutureBuilder<List<MarketDataPoint>>(
      future: _service.fetchHistoricalPrices(_selectedCommodity),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(height: 100); // Placeholder space
        }

        final prices = snapshot.data!.map((d) => d.price).toList();
        final highPrice = prices.reduce((a, b) => a > b ? a : b);
        final lowPrice = prices.reduce((a, b) => a < b ? a : b);
        final change = highPrice - lowPrice;

        return Row(
          children: [
            _buildStatCard(
              icon: Icons.trending_up,
              title: '30-Day High',
              value: 'Rs ${highPrice.toStringAsFixed(2)}',
              color: AppColors.darkGreen,
            ),
            const SizedBox(width: AppSpacing.medium),
            _buildStatCard(
              icon: Icons.trending_down,
              title: '30-Day Low',
              value: 'Rs ${lowPrice.toStringAsFixed(2)}',
              color: Colors.red.shade700,
            ),
            const SizedBox(width: AppSpacing.medium),
            _buildStatCard(
              icon: Icons.attach_money,
              title: 'Max Fluctuation',
              value: 'Rs ${change.toStringAsFixed(2)}',
              color: AppColors.accentYellow,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value, required Color color}) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: AppSpacing.small),
              Text(title, style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: AppSpacing.xsmall),
              Text(value, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
            ],
          ),
        ),
      ),
    );
  }
}