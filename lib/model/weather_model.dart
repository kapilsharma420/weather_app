class Weather {
  final String city;
  final double temperature;
  final double feelsLike;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int visibility; // in meters
  final int timezone;
  final int sunrise; // in UNIX time
  final int sunset;

  Weather({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.timezone,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];
    final sys = json['sys'];

    return Weather(
      city: json['name'],
      temperature: main['temp'],
      feelsLike: main['feels_like'],
      description: weather['description'],
      icon: weather['icon'],
      humidity: main['humidity'],
      windSpeed: wind['speed'].toDouble(),
      visibility: json['visibility'],
      timezone: json['timezone'],
      sunrise: sys['sunrise'],
      sunset: sys['sunset'],
    );
  }
}
