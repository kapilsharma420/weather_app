class Weather {
  final String city;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int timezone;

  Weather({
    required this.city,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.timezone,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];

    return Weather(
      city: json['name'],
      temperature: main['temp'],
      description: weather['description'],
      icon: weather['icon'],
      humidity: main['humidity'],
      windSpeed: wind['speed'].toDouble(),
      timezone: json['timezone'],
    );
  }
}
