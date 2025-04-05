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
    'Delhi',
    'Gurgaon',
    'Hisar',
    'Rohtak',
    'Karnal',
    'Ambala',
    'Panipat',
    'Yamunanagar',
    'Sirsa',
    'Faridabad',
    'Panchkula',
    'Rewari',
    'Kurukshetra',
    'Jhajjar',
    'Jind',
    // Add more cities if needed
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
    filteredCities = allCities
        .where((city) => city.toLowerCase().startsWith(value.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void clearSuggestions() {
    filteredCities.clear();
    notifyListeners();
  }
}