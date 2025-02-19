import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/search/view/search_page.dart';
import 'package:flutter_weather/settings/view/settings_page.dart';
import 'package:flutter_weather/theme/cubit/theme_cubit.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:flutter_weather/weather/models/models.dart';
import 'package:flutter_weather/weather/view/weather_page.dart';
import 'package:flutter_weather/weather/widgets/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

import '../../helper/hydrated_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockThemeCubit extends MockCubit<Color> implements ThemeCubit {}

class MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

void main() {
  initHydratedStorage();

  group('weatherPage', () {
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherRepository = MockWeatherRepository();
    });

    testWidgets('renders weatherView', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: weatherRepository,
          child: const MaterialApp(home: WeatherPage()),
        ),
      );
      expect(find.byType(WeatherView), findsOneWidget);
    });
  });

  group('WeatherView', () {
    final weather = Weather(
      condition: WeatherCondition.cloudy,
      lastUpdated: DateTime(2020),
      location: 'London',
      temperature: const Temperature(value: 4.2),
    );

    late ThemeCubit themeCubit;
    late WeatherCubit weatherCubit;

    setUp(() {
      themeCubit = MockThemeCubit();
      weatherCubit = MockWeatherCubit();
    });

    testWidgets('renders WeatherEmpty for WeatherStatus.initial',
            (tester) async {
          when(() => weatherCubit.state).thenReturn(WeatherState());
          await tester.pumpWidget(
            BlocProvider.value(
              value: weatherCubit,
              child: const MaterialApp(home: WeatherView()),
            ),
          );
          expect(find.byType(WeatherEmpty), findsOneWidget);
        });

    testWidgets('renders WeatherLoading for WeatherStatus.loading',
            (tester) async {
          when(() => weatherCubit.state).thenReturn(
            WeatherState(status: WeatherStatus.loading),
          );
          await tester.pumpWidget(
            BlocProvider.value(
              value: weatherCubit,
              child: const MaterialApp(home: WeatherView()),
            ),
          );
          expect(find.byType(WeatherLoading), findsOneWidget);
        });

    testWidgets('renders WeatherPopulated for WeatherStatus.success',
            (tester) async {
          when(() => weatherCubit.state).thenReturn(
            WeatherState(
              status: WeatherStatus.success,
              weather: weather,
            ),
          );
          await tester.pumpWidget(
            BlocProvider.value(
              value: weatherCubit,
              child: const MaterialApp(home: WeatherView()),
            ),
          );
          expect(find.byType(WeatherPopulated), findsOneWidget);
        });

    testWidgets('renders WeatherError for WeatherStatus.failure',
            (tester) async {
          when(() => weatherCubit.state).thenReturn(
            WeatherState(
              status: WeatherStatus.failure,
            ),
          );
          await tester.pumpWidget(
            BlocProvider.value(
              value: weatherCubit,
              child: const MaterialApp(home: WeatherView()),
            ),
          );
          expect(find.byType(WeatherError), findsOneWidget);
        });

    testWidgets('navigation to SettingsPage when setting icon is tapped',
            (tester) async {
          when(() => weatherCubit.state).thenReturn(WeatherState());
          await tester.pumpWidget(
            BlocProvider.value(
              value: weatherCubit,
              child: const MaterialApp(home: WeatherView()),
            ),
          );
          await tester.tap(find.byType(IconButton));
          await tester.pumpAndSettle();
          expect(find.byType(SettingsPage), findsOneWidget);
        });

    testWidgets('navigation to SearchPage when search button is tapped',
            (tester) async {
          when(() => weatherCubit.state).thenReturn(WeatherState());
          await tester.pumpWidget(
            BlocProvider.value(
              value: weatherCubit,
              child: const MaterialApp(home: WeatherView()),
            ),
          );
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          expect(find.byType(SearchPage), findsOneWidget);
        });

    testWidgets('calls updateTheme when weather changes', (tester) async {
      whenListen(
        weatherCubit,
        Stream<WeatherState>.fromIterable([
          WeatherState(),
          WeatherState(status: WeatherStatus.success, weather: weather)
        ]),
      );
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
        ),
      );
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: themeCubit),
            BlocProvider.value(value: weatherCubit),
          ],
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      verify(() => themeCubit.updateTheme(weather)).called(1);
    });

    testWidgets('triggers refreshWeather on pull to refresh', (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
        ),
      );
      when(() => weatherCubit.refreshWeather()).thenAnswer((_) async => {});
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      await tester.fling(
        find.text('London'),
        const Offset(0, 500),
        1000,
      );
      await tester.pumpAndSettle();
      verify(() => weatherCubit.refreshWeather()).called(1);
    });

    testWidgets('triggers fetch on search pop', (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      when(() => weatherCubit.fetchWeather(any())).thenAnswer((_) async => {});
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Chicago');
      await tester.tap(find.byKey(const Key('searchPage_search_iconButton')));
      await tester.pumpAndSettle();
      verify(() => weatherCubit.fetchWeather('Chicago')).called(1);
    });

    testWidgets('state is cached', (tester) async {
      when<dynamic>(() => hydratedStorage.read('$WeatherCubit')).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
          temperatureUnits: TemperatureUnits.fahrenheit,
        ).toJson(),
      );
      await tester.pumpWidget(
          BlocProvider.value(
            value: WeatherCubit(MockWeatherRepository()),
            child: const MaterialApp(home: WeatherView()),
          )
      );
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });
  });
}
