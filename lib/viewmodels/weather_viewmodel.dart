import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:whether_app/model/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// ViewModel for managing weather-related logic and state
class WeatherViewModel extends ChangeNotifier {
  final TextEditingController cityController = TextEditingController();
  bool isLoading = false;
  bool isCurrentLocation = false;

  Weather? weather;
  String? errorMessage;
  List<String> filteredCities = [];

  // List of popular cities used for suggestions
  final List<String> allCities = [
    // India - Major Cities
    'Delhi', 'Mumbai', 'Kolkata', 'Chennai', 'Bangalore', 'Hyderabad', 'Ahmedabad',
    'Pune', 'Jaipur', 'Lucknow', 'Kanpur', 'Nagpur', 'Indore', 'Bhopal',
    'Ludhiana', 'Patna', 'Vadodara', 'Surat', 'Agra', 'Ranchi', 'Chandigarh',
    'Amritsar', 'Noida', 'Gurgaon', 'Faridabad', 'Ghaziabad',

    // India - Haryana Districts
    'Hisar', 'Rohtak', 'Karnal', 'Ambala', 'Panipat', 'Yamunanagar', 'Sirsa',
    'Panchkula', 'Rewari', 'Kurukshetra', 'Jhajjar', 'Jind', 'Kaithal', 'Bhiwani',
    'Mahendragarh', 'Fatehabad', 'Palwal', 'Nuh', 'Charkhi Dadri',

    // International Cities
    // USA
    'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia',
    'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin', 'Miami', 'Atlanta',

    // UK
    'London', 'Manchester', 'Birmingham', 'Liverpool', 'Glasgow', 'Edinburgh',

    // Canada
    'Toronto', 'Vancouver', 'Montreal', 'Calgary', 'Ottawa', 'Edmonton',

    // Australia
    'Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide',

    // Europe
    'Paris', 'Berlin', 'Rome', 'Madrid', 'Barcelona', 'Vienna', 'Amsterdam',
    'Prague', 'Warsaw', 'Lisbon', 'Brussels', 'Budapest', 'Athens',

    // Asia
    'Tokyo', 'Seoul', 'Bangkok', 'Singapore', 'Kuala Lumpur', 'Jakarta',
    'Manila', 'Beijing', 'Shanghai', 'Hong Kong', 'Dubai',

    // Africa
    'Cairo', 'Lagos', 'Nairobi', 'Cape Town', 'Johannesburg',

    // South America
    'São Paulo', 'Rio de Janeiro', 'Buenos Aires', 'Lima', 'Bogotá', 'Santiago',

    // Middle East
    'Riyadh', 'Doha', 'Tehran', 'Kuwait City', 'Muscat', 'Jerusalem'
  ];

  // Fetch weather using current GPS location
  Future<void> fetchWeatherFromLocation() async {
    isLoading = true;
    weather = null;
    errorMessage = null;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage = "Location services are disabled.";
        isLoading = false;
        notifyListeners();
        return;
      }

      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage = "Location permission denied.";
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage = "Location permissions are permanently denied.";
        isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address (placemark) info from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Try different location fields to extract city name
        List<String?> cityCandidates = [
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
        ];

        // Try to fetch weather for each candidate
        for (var candidate in cityCandidates) {
          if (candidate != null && candidate.isNotEmpty) {
            final cleanCity = candidate.replaceAll(RegExp(r'[^\w\s]'), '').trim();
            final success = await tryFetchWeather(cleanCity);
            if (success) {
              cityController.text = cleanCity;
              isCurrentLocation = true;
              break;
            }
          }
        }

        if (weather == null) {
          errorMessage = "Couldn't fetch weather for your current location.";
        }
      } else {
        errorMessage = "Location not found.";
      }
    } catch (e) {
      errorMessage = "Unable to fetch location.";
    }

    isLoading = false;
    notifyListeners();
  }

  // Format Unix timestamp and timezone offset into readable time (e.g., 6:45 PM)
  String formatTime(int timestamp, int timezoneOffset) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch((timestamp + timezoneOffset) * 1000, isUtc: true);
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Helper function to fetch weather and return success flag
  Future<bool> tryFetchWeather(String city) async {
    const apiKey = '105423fbdd8f398a18bd5d80ca642ec8';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        weather = Weather.fromJson(data);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Fetch weather by manually entered city
  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) return;

    isCurrentLocation = false;
    isLoading = true;
    weather = null;
    errorMessage = null;
    notifyListeners();

    const apiKey = '105423fbdd8f398a18bd5d80ca642ec8';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        weather = Weather.fromJson(data);
        errorMessage = null;
      } else {
        weather = null;
        errorMessage = "City not found. Please try again.";
      }
    } catch (e) {
      weather = null;
      errorMessage = "Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Get formatted local time string for the weather city
  String getFormattedDate() {
    if (weather == null) return '';
    final nowUtc = DateTime.now().toUtc();
    final cityTime = nowUtc.add(Duration(seconds: weather!.timezone));
    return DateFormat.yMMMMEEEEd().add_jm().format(cityTime);
  }

  // Filter city suggestions based on user input
  void updateSuggestions(String value) {
    final query = value.toLowerCase().trim();
    filteredCities = allCities
        .where((city) => city.toLowerCase().contains(query))
        .toList();
    notifyListeners();
  }

  // Clear city suggestions
  void clearSuggestions() {
    filteredCities.clear();
    notifyListeners();
  }
}
