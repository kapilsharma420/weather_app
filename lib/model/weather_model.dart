// A data model class representing weather information
class Weather {
  final String city;           // Name of the city
  final double temperature;    // Current temperature in Celsius
  final double feelsLike;      // "Feels like" temperature in Celsius
  final String description;    // Weather condition description (e.g., "clear sky")
  final String icon;           // Icon code from OpenWeatherMap to display weather visuals
  final int humidity;          // Humidity percentage
  final double windSpeed;      // Wind speed in meters per second
  final int visibility;        // Visibility in meters
  final int timezone;          // Timezone offset from UTC in seconds
  final int sunrise;           // Sunrise time in UNIX timestamp
  final int sunset;            // Sunset time in UNIX timestamp

  // Constructor to initialize all fields
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

  // Factory constructor to create a Weather object from a JSON response
  factory Weather.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];  // Weather info (icon, description, etc.)
    final main = json['main'];           // Temperature, humidity, feels_like, etc.
    final wind = json['wind'];           // Wind speed
    final sys = json['sys'];             // Sunrise, sunset, etc.

    return Weather(
      city: json['name'],                         // City name
      temperature: main['temp'],                  // Current temperature
      feelsLike: main['feels_like'],              // Feels like temperature
      description: weather['description'],        // Weather description
      icon: weather['icon'],                      // Weather icon ID
      humidity: main['humidity'],                 // Humidity percentage
      windSpeed: wind['speed'].toDouble(),        // Wind speed
      visibility: json['visibility'],             // Visibility in meters
      timezone: json['timezone'],                 // Timezone offset in seconds
      sunrise: sys['sunrise'],                    // Sunrise time (UNIX)
      sunset: sys['sunset'],                      // Sunset time (UNIX)
    );
  }
}
