import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Top Weather Header
              Container(
                padding: const EdgeInsets.all(20),
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
                    Text("07 July, Monday",
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Bamban, Tarlac",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Rainy Day",
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 10),

                    // 🌡 Temp + Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("22°C",
                                style: GoogleFonts.poppins(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text("Feels like 32°C",
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: Colors.white70)),
                          ],
                        ),

                        Image.asset(
                          "assets/images/rainy.png", // your weather icon
                          height: 150,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🔹 Hourly Forecast
              Container(
                padding: const EdgeInsets.all(12),
                height: 150,
                color: const Color(0xFF162C55),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TODAY'S WEATHER",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 90, // ✅ fixed height instead of Expanded
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true, // ✅ fixes overflow
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _hourlyCard("10:00", "🌤", "23°C"),
                          _hourlyCard("13:00", "🌧", "22°C"),
                          _hourlyCard("16:00", "⛈", "21°C"),
                          _hourlyCard("19:00", "🌙", "20°C"),
                          _hourlyCard("22:00", "🌙", "19°C"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Weekly Forecast
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF0F1D38),
                height: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("WEEKLY FORECAST",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500)),
                        const Spacer(),
                        const Icon(Icons.arrow_back_ios,
                            size: 14, color: Colors.white70),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 140, // ✅ fixed height instead of Expanded
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true, // ✅ fixes overflow
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _weeklyCard("Tue", "⛈", "27°C"),
                          _weeklyCard("Today", "☀", "24°C", isToday: true),
                          _weeklyCard("Thu", "⛈", "27°C"),
                          _weeklyCard("Fri", "🌤", "25°C"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Hourly Card Widget
  Widget _hourlyCard(String time, String emoji, String temp) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF203A77),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          Text(emoji, style: const TextStyle(fontSize: 20)),
          Text(temp,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }

  // 🔹 Weekly Card Widget
  Widget _weeklyCard(String day, String emoji, String temp,
      {bool isToday = false}) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFF203A77) : const Color(0xFF162C55),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(temp,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}
