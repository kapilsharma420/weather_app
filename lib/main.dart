import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/weather_viewmodel.dart';
import 'views/wether_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherViewModel(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WeatherHomePage(),
      ),
    );
  }
}



//main wale me change kiye the not response ho gy 
