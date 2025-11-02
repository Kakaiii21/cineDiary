import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../models/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with WidgetsBindingObserver {
  final WeatherService weatherService = WeatherService();
  final TextEditingController controller = TextEditingController();

  Future<Weather>? weatherFuture;
  List<Map<String, dynamic>> hourlyForecast = [];
  List<Map<String, dynamic>> weeklyForecast = [];

  final String apiKey = '6706051f07711ea899d81158b8eb1ccc';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 👈 Add observer
    _handlePermissionAndFetchWeather();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 👈 Remove observer
    super.dispose();
  }

  // 👇 Automatically retry when app resumes from background (e.g. after settings)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handlePermissionAndFetchWeather();
    }
  }

  Future<void> _handlePermissionAndFetchWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }
      }

      // ✅ Fast and accurate
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final city = placemarks.first.locality ?? 'Unknown';
        controller.text = city;

        // Fetch all data in parallel — no waiting delay
        final weatherFutureLocal = weatherService.fetchWeather(city);
        final hourlyFuture = fetchHourlyWeather(
          position.latitude,
          position.longitude,
        );
        final weeklyFuture = fetchWeeklyWeather(
          position.latitude,
          position.longitude,
        );

        final results = await Future.wait([
          weatherFutureLocal,
          hourlyFuture,
          weeklyFuture,
        ]);

        setState(() {
          weatherFuture = Future.value(results[0] as Weather);
          hourlyForecast = results[1] as List<Map<String, dynamic>>;
          weeklyForecast = results[2] as List<Map<String, dynamic>>;
        });
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (title.contains('Disabled')) {
                // Open device location settings
                await Geolocator.openLocationSettings();
              } else if (title.contains('Permanently Denied')) {
                // Open app settings for permissions
                await Geolocator.openAppSettings();
              }
              // Retry fetching after user enables location
              _handlePermissionAndFetchWeather();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ✅ Remove the duplicate function — only keep ONE of these:
  Future<List<Map<String, dynamic>>> fetchHourlyWeather(
    double lat,
    double lon,
  ) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final forecasts = (data['list'] as List)
          .take(8)
          .toList(); // 24-hour (3h interval)
      return forecasts.map<Map<String, dynamic>>((item) {
        return {
          'time': item['dt_txt'] ?? '',
          'temp': (item['main']['temp'] as num).toDouble(),
          'icon': item['weather'][0]['icon'] ?? '01d',
        };
      }).toList();
    } else {
      debugPrint('Hourly request failed: ${response.body}');
      return [];
    }
  }

  // ✅ Add this missing function:
  Future<List<Map<String, dynamic>>> fetchWeeklyWeather(
    double lat,
    double lon,
  ) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final forecasts = data['list'] as List;

      final Map<String, List<double>> tempsByDay = {};
      final Map<String, String> iconByDay = {};

      for (var item in forecasts) {
        final date = DateTime.parse(item['dt_txt']);
        final day = DateFormat('yyyy-MM-dd').format(date);
        final temp = (item['main']['temp'] as num).toDouble();
        final icon = item['weather'][0]['icon'] as String;

        tempsByDay.putIfAbsent(day, () => []).add(temp);
        iconByDay[day] = icon;
      }

      final List<Map<String, dynamic>> weekly = tempsByDay.entries.map((entry) {
        final temps = entry.value;
        return {
          'date': DateTime.parse(entry.key),
          'tempMin': temps.reduce((a, b) => a < b ? a : b),
          'tempMax': temps.reduce((a, b) => a > b ? a : b),
          'icon': iconByDay[entry.key],
        };
      }).toList();

      weekly.sort((a, b) => a['date'].compareTo(b['date']));
      return weekly.take(5).toList(); // show 5 days
    } else {
      debugPrint('Weekly request failed: ${response.body}');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM, EEEE').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (weatherFuture != null)
                FutureBuilder<Weather>(
                  future: weatherFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error fetching weather data',
                          style: GoogleFonts.poppins(color: Colors.redAccent),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final weather = snapshot.data!;
                      return Column(
                        children: [
                          _buildCurrentWeather(weather, formattedDate),
                          if (hourlyForecast.isNotEmpty) _buildHourlyForecast(),
                          if (weeklyForecast.isNotEmpty) _buildWeeklyForecast(),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                )
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white70),
                        const SizedBox(height: 20),
                        Text(
                          "Fetching your location... 🌍",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(Weather weather, String date) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A529E), Color(0xFF0F1D38)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Text(
            weather.cityName,
            style: GoogleFonts.poppins(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            weather.description,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${weather.temperature}°C",
                    style: GoogleFonts.poppins(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "FEELS LIKE ${weather.feelsLike ?? weather.temperature}°C",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Image.network(
                'https://openweathermap.org/img/wn/${weather.icon}@4x.png',
                height: 150,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B2A50), Color(0xFF22366B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              "TODAY'S WEATHER",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: hourlyForecast.map((hour) {
                    final time = DateTime.parse(hour['time']);
                    final formattedTime =
                        '${time.hour.toString().padLeft(2, '0')}:00';
                    return Container(
                      height: 140,
                      width: 95,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formattedTime,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Image.network(
                            'https://openweathermap.org/img/wn/${hour['icon']}@4x.png',
                            height: 80,
                          ),
                          Text(
                            '${hour['temp'].toStringAsFixed(1)}°C',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF102544), Color(0xFF1D3B70)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              "WEEKLY FORECAST",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: weeklyForecast.map((day) {
                final dayName = DateFormat('EEEE').format(day['date']);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dayName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      Row(
                        children: [
                          Image.network(
                            'https://openweathermap.org/img/wn/${day['icon']}@2x.png',
                            height: 45,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${day['tempMax'].toStringAsFixed(0)}° / ${day['tempMin'].toStringAsFixed(0)}°',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
