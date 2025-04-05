import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:whether_app/model/weather_model.dart';

class WeatherViewModel extends ChangeNotifier {
  final TextEditingController cityController = TextEditingController();
  bool isLoading = false;
  Weather? weather;
  String? errorMessage;
  List<String> filteredCities = [];

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

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) return;

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

  String getFormattedDate() {
    if (weather == null) return '';
    final nowUtc = DateTime.now().toUtc();
    final cityTime = nowUtc.add(Duration(seconds: weather!.timezone));
    return DateFormat.yMMMMEEEEd().add_jm().format(cityTime);
  }

 void updateSuggestions(String value) {
  final query = value.toLowerCase().trim();
  filteredCities = allCities
      .where((city) => city.toLowerCase().contains(query))
      .toList();
  notifyListeners();
}

  void clearSuggestions() {
    filteredCities.clear();
    notifyListeners();
  }
}