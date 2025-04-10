import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whether_app/theme/theme_provider.dart';

import 'viewmodels/weather_viewmodel.dart';
import 'views/weather_home_page.dart';

void main() {
  // Entry point of the Flutter app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // MultiProvider allows providing multiple ChangeNotifiers
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        // Rebuilds the MaterialApp when the theme changes
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false, // Hides the debug banner
            theme: ThemeData.light(), // Light theme configuration
            darkTheme: ThemeData.dark(), // Dark theme configuration
            themeMode:
                themeProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light, // Chooses the theme based on state
            home: const WeatherHomePage(), // Starting screen
          );
        },
      ),
    );
  }
}
