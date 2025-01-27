class Weather {
  final String description;
  final String icon;
  final double temperature;
  final DateTime date;

  Weather({required this.description, required this.icon, required this.temperature, required this.date});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temperature: json['main']['temp'] - 273.15, // Convert Kelvin to Celsius
      date: DateTime.parse(json['dt_txt']),
    );
  }
}
