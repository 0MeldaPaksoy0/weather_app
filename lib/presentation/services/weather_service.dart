import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchWeather(double latitude, double longitude) async {
  final String apiKey = 'YOUR_API_KEY'; // Replace with your actual API key
  final String url =
      'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&cnt=5&units=metric&appid=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data; // Returns the parsed JSON data
  } else {
    throw Exception('Failed to load weather data');
  }
}
