import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = '7d784b92124e941476b46158352cd7a1';
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getCurrentWeather(
    double lat,
    double lon,
  ) async {
    final uri = Uri.parse(
      '$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  // Keep the old method for backward compatibility
  Future<Map<String, dynamic>> fetchCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    return getCurrentWeather(lat, lon);
  }
}
