import '../data/repositories/weather_repository.dart';
import '../data/models/weather_model.dart';

class WeatherUseCase {
  final WeatherRepository repository;

  WeatherUseCase(this.repository);

  Future<List<Weather>> fetchWeather(String city) {
    return repository.getFiveDayForecast(city);
  }
}
