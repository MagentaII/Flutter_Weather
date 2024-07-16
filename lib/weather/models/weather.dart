import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

enum TemperatureUnits {
  fahrenheit,
  celsius,
}

extension TemperatureUnitsX on TemperatureUnits {
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;
  bool get isCelsius => this == TemperatureUnits.celsius;
}

@JsonSerializable()
class Weather extends Equatable {
  final WeatherCondition condition;
  final DateTime lastUpdated;
  final String location;
  final Temperature temperature;

  const Weather({
    required this.condition,
    required this.lastUpdated,
    required this.location,
    required this.temperature,
  });

  @override
  List<Object> get props => [condition, lastUpdated, location, temperature];

  factory Weather.fromJson(Map<String, dynamic> json) {
    return _$WeatherFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$WeatherToJson(this);
  }

  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
      condition: weather.condition,
      lastUpdated: DateTime.now(),
      location: weather.location,
      temperature: Temperature(value: weather.temperature),
    );
  }

  static final empty = Weather(
    condition: WeatherCondition.unknown,
    lastUpdated: DateTime(0),
    location: '--',
    temperature: const Temperature(value: 0),
  );

  Weather copyWith({
    WeatherCondition? condition,
    DateTime? lastUpdated,
    String? location,
    Temperature? temperature,
  }) {
    return Weather(
      condition: condition ?? this.condition,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
    );
  }
}

@JsonSerializable()
class Temperature extends Equatable {
  final double value;

  const Temperature({required this.value});

  @override
  List<Object> get props => [value];

  factory Temperature.fromJson(Map<String, dynamic> json) {
    return _$TemperatureFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$TemperatureToJson(this);
  }
}
