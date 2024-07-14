part of 'weather_cubit.dart';

enum WeatherStatus {
  initial,
  loading,
  success,
  failure,
}

extension WeatherStatusX on WeatherStatus {
  bool get isInitial => this == WeatherStatus.initial;
  bool get isLoading => this == WeatherStatus.loading;
  bool get isSuccess => this == WeatherStatus.success;
  bool get isFailure => this == WeatherStatus.failure;
}

@JsonSerializable()
final class WeatherState extends Equatable {
  final WeatherStatus status;
  final Weather weather;
  final TemperatureUnits temperatureUnits;

  WeatherState({
    this.status = WeatherStatus.initial,
    Weather? weather,
    this.temperatureUnits = TemperatureUnits.celsius,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, dynamic> json) {
    return _$WeatherStateFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$WeatherStateToJson(this);
  }

  WeatherState copyWith({
    WeatherStatus? status,
    Weather? weather,
    TemperatureUnits? temperatureUnits,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
    );
  }

  @override
  List<Object?> get props => [status, weather, temperatureUnits];
}
