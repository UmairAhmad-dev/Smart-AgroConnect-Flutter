// lib/services/weather_service.dart (Updated to read location from SharedPreferences)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // REQUIRED
import '../models/weather_model.dart';


const String _apiKey = 'e0b97924adc5ca5ff587e11f2f3430c5';
const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
const String _locationKey = 'default_weather_location'; // KEY for SharedPreferences

class WeatherService {

  // FIX: Removed hardcoded city

  Future<ForecastWrapper> fetchFiveDayForecast() async {
    // 1. Get location from local storage (default to Lahore if not found)
    final prefs = await SharedPreferences.getInstance();
    final String city = prefs.getString(_locationKey) ?? 'Lahore'; // Lahore is the default fallback

    final url = Uri.parse(
      // Use the fetched city name in the API call
        '$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // ... (Grouping logic remains the same) ...
      final rawList = jsonResponse['list'] as List;
      final dailyMap = <String, DailyWeather>{};

      for (var entry in rawList) {
        final dt = DateTime.fromMillisecondsSinceEpoch(entry['dt'] * 1000);
        final dayKey = DateFormat('yyyy-MM-dd').format(dt);

        // ... (rest of the temperature parsing logic remains the same) ...
        final tempMin = (entry['main']['temp_min'] as num).toDouble();
        final tempMax = (entry['main']['temp_max'] as num).toDouble();
        final weather = entry['weather'][0];

        if (!dailyMap.containsKey(dayKey)) {
          dailyMap[dayKey] = DailyWeather(
            date: dt,
            maxTemp: tempMax,
            minTemp: tempMin,
            description: weather['description'],
            iconCode: weather['icon'],
          );
        } else {
          var currentDay = dailyMap[dayKey]!;
          dailyMap[dayKey] = DailyWeather(
            date: currentDay.date,
            maxTemp: tempMax > currentDay.maxTemp ? tempMax : currentDay.maxTemp,
            minTemp: tempMin < currentDay.minTemp ? tempMin : currentDay.minTemp,
            description: currentDay.description,
            iconCode: currentDay.iconCode,
          );
        }
      }

      return ForecastWrapper(
        timezone: jsonResponse['city']['name'],
        dailyForecast: dailyMap.values.toList().take(5).toList(),
      );

    } else {
      throw Exception('API Error (${response.statusCode}): Failed to load forecast for $city. Check API Key and network.');
    }
  }
}