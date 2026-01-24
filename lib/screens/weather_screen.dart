import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  late Future<Map<String, dynamic>> _weatherFuture;

  // Example: Sunyani / Ghana
  final double latitude = 7.3399;
  final double longitude = -2.3268;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _loadWeather();
  }
  Future<Map<String, dynamic>> _loadWeather() async {
    final position = await _locationService.getCurrentLocation();
    return _weatherService.fetchCurrentWeather(
      lat: position.latitude,
      lon: position.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Weather'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final temp = data['main']['temp'];
          final description = data['weather'][0]['description'];
          final city = data['name'];
          final humidity = data['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      city,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${temp.toString()} °C',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description.toUpperCase(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text('Humidity: $humidity%'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
