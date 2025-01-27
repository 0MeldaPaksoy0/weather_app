import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherRepository {
  final String apiKey = 'e3c58be97905cdffd190cdd1cf383b59';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  Future<List<Weather>> getFiveDayForecast(String city) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$city&appid=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List weatherList = data['list'];
      return weatherList.map((json) => Weather.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }
}
