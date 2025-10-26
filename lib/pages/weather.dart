// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:proj1/models/weather_service.dart';

import '../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService weatherService = WeatherService();
  final TextEditingController controller = TextEditingController();

  Future<Weather>? weatherFuture;
  Weather? currentWeather;
  List<Map<String, dynamic>> hourlyForecast = [];
  List<Map<String, dynamic>> weeklyForecast = [];

  final String apiKey = '6706051f07711ea899d81158b8eb1ccc'; // ✅ your API key

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showPopup('Location Disabled', 'Please enable location services.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPopup(
          'Permission Denied',
          'Location permission is required to show weather for your area.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPopup(
        'Permission Permanently Denied',
        'Please enable location permission manually in settings.',
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      String city = placemarks.first.locality ?? 'Unknown';
      controller.text = city;
      setState(() {
        weatherFuture = weatherService.fetchWeather(city);
      });

      hourlyForecast = await fetchHourlyWeather(
        position.latitude,
        position.longitude,
      );
      weeklyForecast = await fetchWeeklyWeather(
        position.latitude,
        position.longitude,
      );
      setState(() {});
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
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ✅ Hourly (24-hour) forecast from 2.5 API
  Future<List<Map<String, dynamic>>> fetchHourlyWeather(
    double lat,
    double lon,
  ) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List forecasts = data['list'].take(8).toList();
      return forecasts.map<Map<String, dynamic>>((item) {
        return {
          'time': item['dt_txt'],
          'temp': item['main']['temp'],
          'icon': item['weather'][0]['icon'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load hourly weather data');
    }
  }

  // ✅ Weekly forecast (7-day) from One Call 3.0 API
  Future<List<Map<String, dynamic>>> fetchWeeklyWeather(
    double lat,
    double lon,
  ) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List forecasts = data['list'];

      Map<String, List<double>> dailyTemps = {};
      Map<String, String> dailyIcons = {};

      for (var item in forecasts) {
        DateTime date = DateTime.parse(item['dt_txt']);
        String day = DateFormat('yyyy-MM-dd').format(date);
        double temp = item['main']['temp'];
        String icon = item['weather'][0]['icon'];

        dailyTemps.putIfAbsent(day, () => []).add(temp);
        dailyIcons[day] = icon;
      }

      List<Map<String, dynamic>> weekly = [];
      int count = 0;
      for (var entry in dailyTemps.entries) {
        if (count >= 7) break; // Only first 7 days
        var temps = entry.value;
        weekly.add({
          'date': DateTime.parse(entry.key),
          'tempMin': temps.reduce((a, b) => a < b ? a : b),
          'tempMax': temps.reduce((a, b) => a > b ? a : b),
          'icon': dailyIcons[entry.key],
        });
        count++;
      }

      return weekly;
    } else {
      throw Exception('Failed to load weekly weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM, EEEE').format(DateTime.now());

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
                      currentWeather = weather;

                      return Column(
                        children: [
                          _buildCurrentWeather(weather, formattedDate),
                          if (hourlyForecast.isNotEmpty) _buildHourlyForecast(),
                          if (weeklyForecast.isNotEmpty) _buildWeeklyForecast(),
                        ],
                      );
                    }
                    return Container();
                  },
                ),
              if (weatherFuture == null)
                SizedBox(
                  height: MediaQuery.of(
                    context,
                  ).size.height, // full screen height
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
                    DateTime time = DateTime.parse(hour['time']);
                    String formattedTime =
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
                String dayName = DateFormat('EEEE').format(day['date']);
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
