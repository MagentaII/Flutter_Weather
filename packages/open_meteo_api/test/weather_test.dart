import 'package:flutter_test/flutter_test.dart';
import 'package:open_meteo_api/open_meteo_api.dart';

void main() {
  group('Weather', () {
    group('fromJson', () {
      test('returns correct Weather object', () {
        expect(
            Weather.fromJson(
              <String, dynamic>{
                'temperature': 15.3,
                'weathercode': 1,
              },
            ),
            isA<Weather>()
                .having((w) => w.temperature, 'temperature', 15.3)
                .having((w) => w.weatherCode, 'weatherCode', 1));
      });
    });
  });
}
