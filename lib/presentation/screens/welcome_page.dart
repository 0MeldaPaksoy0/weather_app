import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'select_day_page.dart';  // Import SelectDayPage

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double? latitude, longitude;
  Map<String, List<dynamic>>? forecastData;
  String? cityName;
  bool showWelcome = true;

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
    final apiKey = 'e3c58be97905cdffd190cdd1cf383b59';
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Forecast for ${cityName ?? 'Your City'}"),
        centerTitle: true,
      ),
      body: forecastData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            if (showWelcome) _buildWelcomeMessage(),
            if (!showWelcome) _buildWeatherContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showWelcome = false;
        });
      },
      child: Center( // Wrap the Column with Center widget
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically within the Column
          crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
          children: [
            SizedBox(height: 50),
            Text("WELCOME", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
            SizedBox(height: 20),

            Text("Tap here to start", style: TextStyle(fontSize: 20, color: Colors.black54)),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Inside _buildWeatherContent() in WelcomePage
  Widget _buildWeatherContent() {
    return Column(
      children: [
        // Enhanced Vertical Days Selection with Weather Icon and Summary
        Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: forecastData?.keys.map((date) {
              // Get the weather condition and temperature for the day
              var dayWeather = forecastData?[date]?[0]; // Take the first weather item of the day
              String condition = dayWeather['weather'][0]['main'] ?? 'No Data';
              double temperature = dayWeather['main']['temp'] ?? 0.0;
              String iconCode = dayWeather['weather'][0]['icon'] ?? '01d'; // Default icon if none provided

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeatherScreen(
                          selectedDate: date,
                          forecastData: forecastData!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          'https://openweathermap.org/img/wn/$iconCode.png', // Weather icon
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$condition, $temperature°C',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList() ??
                [],
          ),
        ),
      ],
    );
  }
}

class WeatherScreen extends StatelessWidget {
  final String selectedDate;
  final Map<String, List<dynamic>> forecastData;

  WeatherScreen({required this.selectedDate, required this.forecastData});

  @override
  Widget build(BuildContext context) {
    final hourlyData = forecastData[selectedDate]!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Weather for $selectedDate"),
        centerTitle: true,
      ),
      body: ListView(
        children: hourlyData.map<Widget>((entry) {
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
