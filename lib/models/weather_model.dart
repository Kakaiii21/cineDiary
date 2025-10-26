class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double feelsLike;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.feelsLike,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: (json['main']['temp']).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      feelsLike: (json['main']['feels_like']).toDouble(),
    );
  }
}
