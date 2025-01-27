import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/weather_model.dart';
import '../../domain/weather_usecase.dart';

class WeatherEvent {}

class FetchWeather extends WeatherEvent {
  final String city;

  FetchWeather(this.city);
}

class WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final List<Weather> weatherList;

  WeatherLoaded(this.weatherList);
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherUseCase weatherUseCase;

  WeatherBloc(this.weatherUseCase) : super(WeatherLoading()) {
    on<FetchWeather>((event, emit) async {
      emit(WeatherLoading());
      try {
        final weatherList = await weatherUseCase.fetchWeather(event.city);
        emit(WeatherLoaded(weatherList));
      } catch (e) {
        emit(WeatherError(e.toString()));
      }
    });
  }
}
