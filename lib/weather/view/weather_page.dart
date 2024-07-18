import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/search/view/search_page.dart';
import 'package:flutter_weather/settings/view/settings_page.dart';
import 'package:flutter_weather/theme/cubit/theme_cubit.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherCubit(context.read<WeatherRepository>()),
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('This is Weather Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              print(
                'Navigation from WeatherPage to SettingsPage at ${DateTime.now()}',
              );
              Navigator.of(context).push(
                SettingsPage.route(context.read<WeatherCubit>()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherCubit, WeatherState>(
          listener: (context, state) {
            if (state.status.isSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case WeatherStatus.initial:
                return const Text('WeatherEmpty');
              case WeatherStatus.loading:
                return const Text('WeatherLoading');
              case WeatherStatus.success:
                return const Text('WeatherPopulated');
              case WeatherStatus.failure:
                return const Text('WeatherError');
              default:
                return const Text('Unknown state');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.search,
          semanticLabel: 'Search',
        ),
        onPressed: () async {
          Navigator.of(context).push(
            SearchPage.route()
          );
        },
      ),
    );
  }
}
