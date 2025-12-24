// lib/models/weather_model.dart (Updated for 7-Day Forecast structure)

import 'package:intl/intl.dart';

// Represents a single day's forecast
class DailyWeather {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String description;
  final String iconCode;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.iconCode,
  });

  // Helper getter for formatted date display
  String get formattedDay => DateFormat('EEE, MMM d').format(date);
  String get formattedDayShort => DateFormat('EEE').format(date); // For smaller cards

  // Factory method to parse data from OpenWeatherMap's 'daily' forecast structure
  factory DailyWeather.fromDailyApi(Map<String, dynamic> json) {
    return DailyWeather(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      // OpenWeatherMap 'daily' object has temp structure
      maxTemp: (json['temp']['max'] as num).toDouble(),
      minTemp: (json['temp']['min'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      iconCode: json['weather'][0]['icon'] as String,
    );
  }
}

// Wrapper model for the full 7-day forecast response
class ForecastWrapper {
  final String timezone; // Useful for display
  final List<DailyWeather> dailyForecast;

  ForecastWrapper({
    required this.timezone,
    required this.dailyForecast,
  });

  factory ForecastWrapper.fromApi(Map<String, dynamic> json) {
    List<DailyWeather> forecastList = [];

    // API returns a list called 'daily' (for One Call API)
    if (json.containsKey('daily')) {
      forecastList = (json['daily'] as List)
          .map((item) => DailyWeather.fromDailyApi(item as Map<String, dynamic>))
          .toList();
    }

    return ForecastWrapper(
      timezone: json['timezone'] as String? ?? 'N/A',
      // We only take the next 7 days (index 0 is today, 1-7 are the forecast)
      dailyForecast: forecastList.take(7).toList(),
    );
  }
}

// Model for Today's snapshot (used on the Dashboard)
class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] as String,
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      iconCode: json['weather'][0]['icon'] as String,
    );
  }
}