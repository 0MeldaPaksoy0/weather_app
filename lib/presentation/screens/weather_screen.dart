import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  final String? selectedDate;

  WeatherScreen({this.selectedDate});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double? latitude, longitude;
  Map<String, List<dynamic>>? forecastData;
  String? cityName;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    await fetchWeather();
  }

  Future<void> fetchWeather() async {
    final apiKey = "apikey";
    final url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cityName = data['city']['name'];
        forecastData = _groupWeatherByDate(data['list']);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Map<String, List<dynamic>> _groupWeatherByDate(List<dynamic> weatherList) {
    Map<String, List<dynamic>> groupedData = {};
    for (var item in weatherList) {
      String date = item['dt_txt'].split(' ')[0];
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(item);
    }
    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = widget.selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: Text("Weather for $selectedDate"),
        centerTitle: true,
      ),
      body: forecastData == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: forecastData![selectedDate]!.map<Widget>((entry) {
          final time = entry['dt_txt'].split(' ')[1];
          final temperature = entry['main']['temp'];
          final condition = entry['weather'][0]['main'];
          final iconCode = entry['weather'][0]['icon'];

          return ListTile(
            leading: Image.network('https://openweathermap.org/img/wn/$iconCode.png'),
            title: Text('$time - $condition'),
            subtitle: Text('Temperature: $temperature°C'),
          );
        }).toList(),
      ),
    );
  }
}
