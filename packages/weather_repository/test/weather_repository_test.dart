import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:weather_repository/src/models/models.dart';
import 'package:weather_repository/src/weather_repository.dart';

class MockOpenMeteoApiClient extends Mock
    implements open_meteo_api.OpenMeteoApiClient {}

class MockLocation extends Mock implements open_meteo_api.Location {}

class MockWeather extends Mock implements open_meteo_api.Weather {}

void main() {
  group('WeatherRepository', () {
    late open_meteo_api.OpenMeteoApiClient weatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockOpenMeteoApiClient();
      weatherRepository = WeatherRepository(weatherApiClient: weatherApiClient);
    });

    group('constructor', () {
      test('instantiate internal weather api client when not injected', () {
        final actual = WeatherRepository();
        final myExpect = isNotNull;
        expect(actual, myExpect);
      });
    });

    group('getWeather', () {
      const city = 'chicago';
      const latitude = 41.85003;
      const longitude = -87.65005;

      test('calls locationSearch with correct city', () async {
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => weatherApiClient.locationSearch(city)).called(1);
      });

      test('throws when locationSearch fails', () async {
        final exception = Exception('oops');
        when(() => weatherApiClient.locationSearch(any())).thenThrow(exception);
        expect(
              () async => weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('calls getWeather with correct latitude/longitude', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
              (_) async => location,
        );
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(
              () =>
              weatherApiClient.getWeather(
                latitude: latitude,
                longitude: longitude,
              ),
        ).called(1);
      });

      test('throws when getWeather fails', () async {
        final exception = Exception('oops');
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
              (_) async => location,
        );
        when(
              () =>
              weatherApiClient.getWeather(
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
              ),
        ).thenThrow(exception);
        expect(
              () async => weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('returns correct weather on success (clear)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.name).thenReturn(city);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(0);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
              (_) async => location,
        );
        when(
              () =>
              weatherApiClient.getWeather(
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
              ),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        final myExpect = Weather(
          location: city,
          temperature: 42.42,
          condition: WeatherCondition.clear,
        );
        expect(actual, myExpect);
      });

      test('returns correct weather on success (cloudy)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.name).thenReturn(city);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(1);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
              (_) async => location,
        );
        when(
              () =>
              weatherApiClient.getWeather(
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
              ),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        final myExpect = Weather(
          location: city,
          temperature: 42.42,
          condition: WeatherCondition.cloudy,
        );
        expect(actual, myExpect);
      });

      test('returns correct weather on success (rainy)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.name).thenReturn(city);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(51);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
              (_) async => location,
        );
        when(
              () =>
              weatherApiClient.getWeather(
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
              ),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        final myExpect = Weather(
          location: city,
          temperature: 42.42,
          condition: WeatherCondition.rainy,
        );
        expect(actual, myExpect);
      });

      test('returns correct weather on success (snowy)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.name).thenReturn(city);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(71);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
              (_) async => location,
        );
        when(
              () =>
              weatherApiClient.getWeather(
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
              ),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        final myExpect = Weather(
          location: city,
          temperature: 42.42,
          condition: WeatherCondition.snowy,
        );
        expect(actual, myExpect);
      });

      test('returns correct weather on success (unknown)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.name).thenReturn(city);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(-1);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
              (_) async => location,
        );
        when(
              () =>
              weatherApiClient.getWeather(
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
              ),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        final myExpect = Weather(
          location: city,
          temperature: 42.42,
          condition: WeatherCondition.unknown,
        );
        expect(actual, myExpect);
      });
    });
  });
}
