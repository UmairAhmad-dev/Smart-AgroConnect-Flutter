// lib/views/home/weather_forecast_screen.dart (Final Professional UI)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// FIX: Ensure the import name is 'weather_service.dart' (singular)
import '../../services/weather_service.dart';
import '../../models/weather_model.dart';

// Reusing constants
abstract class AppSpacing {
  static const double xsmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color primaryBlue = Color(0xFF42A5F5);
}


class WeatherForecastScreen extends StatelessWidget {
  const WeatherForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('7-Day Weather Forecast', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: SizedBox(
          width: 800, // Max width constraint for professional look
          child: FutureBuilder<ForecastWrapper>(
            future: WeatherService().fetchFiveDayForecast(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.darkGreen));
              }
              if (snapshot.hasError) {
                // Display specific error message if the API key failed
                return Center(child: Text('Error: ${snapshot.error}. Check API Key and network!', style: GoogleFonts.roboto(color: Colors.red)));
              }
              if (!snapshot.hasData || snapshot.data!.dailyForecast.isEmpty) {
                return const Center(child: Text('No forecast data available.'));
              }

              final forecast = snapshot.data!;
              // Today is index 0; we display today separately
              final today = forecast.dailyForecast.first;
              final weekForecast = forecast.dailyForecast.skip(1).toList();

              // FIX: CustomScrollView must use SliverPadding, not a 'padding' argument.
              return CustomScrollView(
                slivers: [
                  // --- 1. Today's Highlight Card (Padded) and Header ---
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Today's Main Card
                        _buildTodayHighlight(today, forecast.timezone),
                        const SizedBox(height: AppSpacing.large),

                        // Weekly Forecast List Header
                        Text(
                          'Next 6 Days Outlook',
                          style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                      ]),
                    ),
                  ),

                  // --- 2. Weekly Forecast List (Padded to match) ---
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return _buildWeeklyListItem(weekForecast[index]);
                        },
                        childCount: weekForecast.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTodayHighlight(DailyWeather today, String timezone) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.lightBlue,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today - ${today.formattedDay}',
              style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
            ),
            Text(
              timezone,
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: AppSpacing.large),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Temperature and Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${today.maxTemp.toStringAsFixed(0)}°C',
                      style: GoogleFonts.montserrat(fontSize: 72, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
                    ),
                    Text(
                      'Min: ${today.minTemp.toStringAsFixed(0)}°C',
                      style: GoogleFonts.roboto(fontSize: 18, color: AppColors.darkGreen),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      today.description.toUpperCase(),
                      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                    ),
                  ],
                ),
                // Weather Icon
                Image.network(
                  'http://openweathermap.org/img/wn/${today.iconCode}@4x.png',
                  height: 120,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyListItem(DailyWeather day) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Image.network(
          'http://openweathermap.org/img/wn/${day.iconCode}@2x.png',
          width: 40,
        ),
        title: Text(
          day.formattedDayShort,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          day.description,
          style: GoogleFonts.roboto(color: Colors.grey.shade600),
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Max Temp (Bold)
              Text(
                '${day.maxTemp.toStringAsFixed(0)}°',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: AppSpacing.medium),
              // Min Temp (Faded)
              Text(
                '${day.minTemp.toStringAsFixed(0)}°',
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}