import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:flutter_weather/weather/models/models.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

const city = 'London';
const condition = weather_repository.WeatherCondition.rainy;
const temperatureValueCelsius = 9.8;

class MockWeatherRepository extends Mock
    implements weather_repository.WeatherRepository {}

class MockWeather extends Mock implements weather_repository.Weather {}

void main() {
  group('WeatherCubit', () {
    late weather_repository.Weather weather;
    late weather_repository.WeatherRepository weatherRepository;
    late WeatherCubit weatherCubit;

    setUp(() {
      weather = MockWeather();
      weatherRepository = MockWeatherRepository();
      weatherCubit = WeatherCubit(weatherRepository);
      when(() => weather.location).thenReturn(city);
      when(() => weather.condition).thenReturn(condition);
      when(() => weather.temperature).thenReturn(temperatureValueCelsius);
      when(() => weatherRepository.getWeather(any()))
          .thenAnswer((_) async => weather);
    });

    // initial test
    test('initial state is correct', () {
      final weatherCubit = WeatherCubit(weatherRepository);
      expect(weatherCubit.state, WeatherState());
    });

    group('fetchWeather', () {
      // city is null test
      blocTest<WeatherCubit, WeatherState>(
        'emit nothing when city is null',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(null),
        expect: () => <WeatherState>[],
      );

      // city is empty test
      blocTest<WeatherCubit, WeatherState>(
        'emit nothing when city is empty',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(''),
        expect: () => <WeatherState>[],
      );

      // calls getWeather when city is correct
      blocTest<WeatherCubit, WeatherState>(
        'calls getWeather with correct city',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(city),
        verify: (_) {
          verify(() => weatherRepository.getWeather(city)).called(1);
        },
      );

      // emit [Loading, success] when getWeather returns Fahrenheit
      blocTest<WeatherCubit, WeatherState>(
        'emit [Loading, success] when getWeather returns Fahrenheit',
        build: () => weatherCubit,
        seed: () => WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        act: (cubit) => cubit.fetchWeather(city),
        expect: () => <dynamic>[
          WeatherState(
            status: WeatherStatus.loading,
            temperatureUnits: TemperatureUnits.fahrenheit,
          ),
          isA<WeatherState>()
              .having((w) => w.status, 'WeatherStatus', WeatherStatus.success)
              .having(
                (w) => w.weather,
                'Weather',
                isA<Weather>()
                    .having((w) => w.condition, 'WeatherCondition', condition)
                    .having(
                        (w) => w.lastUpdated, 'WeatherLastUpdated', isNotNull)
                    .having((w) => w.location, 'Location', city)
                    .having(
                      (w) => w.temperature,
                      'Temperature',
                      Temperature(
                          value: temperatureValueCelsius.toFahrenheit()),
                    ),
              ),
        ],
      );

      // emit [Loading, success] when getWeather returns Celsius
      blocTest<WeatherCubit, WeatherState>(
        'emit [Loading, success] when getWeather returns Celsius',
        build: () => weatherCubit,
        seed: () => WeatherState(temperatureUnits: TemperatureUnits.celsius),
        act: (cubit) => cubit.fetchWeather(city),
        expect: () => <dynamic>[
          WeatherState(
            status: WeatherStatus.loading,
            temperatureUnits: TemperatureUnits.celsius,
          ),
          isA<WeatherState>()
              .having((w) => w.status, 'WeatherStatus', WeatherStatus.success)
              .having(
                (w) => w.weather,
                'Weather',
                isA<Weather>()
                    .having((w) => w.condition, 'WeatherCondition', condition)
                    .having(
                        (w) => w.lastUpdated, 'WeatherLastUpdated', isNotNull)
                    .having((w) => w.location, 'Location', city)
                    .having(
                      (w) => w.temperature,
                      'Temperature',
                       Temperature(value: temperatureValueCelsius),
                    ),
              ),
        ],
      );

      // emit [Loading, failure] when getWeather throws
      blocTest(
        'emit [Loading, failure] when getWeather throws',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(city),
        expect: () => <WeatherState>[
          WeatherState(status: WeatherStatus.loading),
          WeatherState(status: WeatherStatus.failure),
        ],
      );
    });

    group('refreshWeather', () {
      // do nothing when weather status is not success
      // (initial weather Status is WeatherStatus.initial)
      blocTest<WeatherCubit, WeatherState>(
        'emit nothing when weather status is not success',
        build: () => weatherCubit,
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) {
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      // do nothing when weather is empty
      blocTest<WeatherCubit, WeatherState>(
        'emit nothing when weather is empty',
        build: () => weatherCubit,
        seed: () => WeatherState(status: WeatherStatus.success),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) {
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      // calls getWeather when location is correct
      blocTest<WeatherCubit, WeatherState>(
        'calls getWeather when location is correct',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            condition: condition,
            lastUpdated: DateTime(2020),
            location: city,
            temperature: Temperature(value: temperatureValueCelsius),
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        verify: (_) {
          verify(() => weatherRepository.getWeather(city)).called(1);
        },
      );

      // do nothing when Exception is thrown
      blocTest<WeatherCubit, WeatherState>(
        'emit nothing when Exception is thrown',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            condition: condition,
            lastUpdated: DateTime(2020),
            location: city,
            temperature: Temperature(value: temperatureValueCelsius),
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
      );

      // refresh weather when getWeather returns Fahrenheit
      blocTest<WeatherCubit, WeatherState>(
        'emit update weather when getWeather returns Fahrenheit',
        build: () => weatherCubit,
        seed: () => WeatherState(
            status: WeatherStatus.success,
            weather: Weather(
              condition: condition,
              lastUpdated: DateTime(2020),
              location: city,
              temperature: Temperature(value: 0),
            ),
            temperatureUnits: TemperatureUnits.fahrenheit),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having((w) => w.status, 'WeatherStatus', WeatherStatus.success)
              .having(
                (w) => w.weather,
                'Weather',
                isA<Weather>()
                    .having((w) => w.condition, 'WeatherCondition', condition)
                    .having(
                        (w) => w.lastUpdated, 'WeatherLastUpdated', isNotNull)
                    .having((w) => w.location, 'WeatherLocation', city)
                    .having(
                      (w) => w.temperature,
                      'Temperature',
                      Temperature(
                        value: temperatureValueCelsius.toFahrenheit(),
                      ),
                    ),
              ),
        ],
      );
      // refresh weather when getWeather returns Celsius
      blocTest<WeatherCubit, WeatherState>(
        'emit update weather when getWeather returns Celsius',
        build: () => weatherCubit,
        seed: () => WeatherState(
            status: WeatherStatus.success,
            weather: Weather(
              condition: condition,
              lastUpdated: DateTime(2020),
              location: city,
              temperature: Temperature(value: 0),
            ),
            temperatureUnits: TemperatureUnits.celsius),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having((w) => w.status, 'WeatherStatus', WeatherStatus.success)
              .having(
                (w) => w.weather,
                'Weather',
                isA<Weather>()
                    .having((w) => w.condition, 'WeatherCondition', condition)
                    .having(
                        (w) => w.lastUpdated, 'WeatherLastUpdated', isNotNull)
                    .having((w) => w.location, 'WeatherLocation', city)
                    .having(
                      (w) => w.temperature,
                      'Temperature',
                      Temperature(
                        value: temperatureValueCelsius,
                      ),
                    ),
              ),
        ],
      );
    });

    group('toggleUnits', () {
      // emit update temperature units when status is not success
      blocTest<WeatherCubit, WeatherState>(
        'emit update units when status is not success',
        build: () => weatherCubit,
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        ],
      );

      // emit update temperature units and temperature value when status is success (Fahrenheit)
      blocTest<WeatherCubit, WeatherState>(
        'emit update units and temperature value '
        'when status is success (Fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            condition: condition,
            lastUpdated: DateTime(2020),
            location: city,
            temperature:
                Temperature(value: temperatureValueCelsius.toFahrenheit()),
          ),
          temperatureUnits: TemperatureUnits.fahrenheit,
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.success,
            weather: Weather(
              condition: condition,
              lastUpdated: DateTime(2020),
              location: city,
              temperature: Temperature(value: temperatureValueCelsius),
            ),
            temperatureUnits: TemperatureUnits.celsius,
          )
        ],
      );

      // emit update temperature units and temperature value when status is success (Celsius)
      blocTest<WeatherCubit, WeatherState>(
        'emit update units and temperature value '
        'when status is success (Celsius)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            condition: condition,
            lastUpdated: DateTime(2020),
            location: city,
            temperature: Temperature(value: temperatureValueCelsius),
          ),
          temperatureUnits: TemperatureUnits.celsius,
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.success,
            weather: Weather(
              condition: condition,
              lastUpdated: DateTime(2020),
              location: city,
              temperature:
                  Temperature(value: temperatureValueCelsius.toFahrenheit()),
            ),
            temperatureUnits: TemperatureUnits.fahrenheit,
          )
        ],
      );
    });

    group('fromJson/toJson', () {
      test('work properly', () {
        final weatherCubit = WeatherCubit(weatherRepository);
        expect(
          weatherCubit.fromJson(weatherCubit.toJson(weatherCubit.state)),
          weatherCubit.state,
        );
      });
    });
  });
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;

  double toCelsius() => (this - 32) * 5 / 9;
}
