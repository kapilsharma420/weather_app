import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whether_app/model/weather_model.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'package:whether_app/theme/theme_provider.dart';

class WeatherHomePage extends StatelessWidget {
  const WeatherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WeatherViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isDarkMode = themeProvider.isDarkMode;
    final gradientColors = isDarkMode
        ? [Colors.blueGrey.shade900, Colors.black]
        : [Colors.lightBlue.shade200, Colors.white];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Weather App', style: Theme.of(context).textTheme.titleLarge),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 320,
                        child: TextField(
                          controller: viewModel.cityController,
                          readOnly: viewModel.isCurrentLocation,
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Enter city',
                            hintStyle: Theme.of(context).textTheme.bodySmall,
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                            suffixIcon: viewModel.isCurrentLocation
                                ? null
                                : IconButton(
                                    icon: Icon(Icons.clear, color: Theme.of(context).iconTheme.color),
                                    onPressed: () {
                                      viewModel.cityController.clear();
                                      viewModel.clearSuggestions();
                                    },
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            viewModel.updateSuggestions(value);
                            viewModel.isCurrentLocation = false;
                          },
                          onSubmitted: (value) {
                            viewModel.fetchWeather(value);
                            viewModel.clearSuggestions();
                          },
                        ),
                      ),
                      if (viewModel.filteredCities.isNotEmpty)
                        Container(
                          width: 320,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: viewModel.filteredCities.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  viewModel.filteredCities[index],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                onTap: () {
                                  viewModel.cityController.text = viewModel.filteredCities[index];
                                  viewModel.fetchWeather(viewModel.cityController.text);
                                  viewModel.clearSuggestions();
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              viewModel.fetchWeather(viewModel.cityController.text);
                            },
                            icon: const Icon(Icons.search),
                            label: const Text('Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: viewModel.fetchWeatherFromLocation,
                            icon: const Icon(Icons.my_location),
                            label: const Text('Use Current Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (viewModel.isLoading)
                  Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                else if (viewModel.weather != null) ...[
                  WeatherCard(
                    weather: viewModel.weather!,
                    dateTime: viewModel.getFormattedDate(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "More Details",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      InfoGridTile(
                        title: 'Sunrise',
                        icon: Icons.wb_sunny,
                        value: viewModel.formatTime(viewModel.weather!.sunrise, viewModel.weather!.timezone),
                      ),
                      InfoGridTile(
                        title: 'Sunset',
                        icon: Icons.nightlight_round,
                        value: viewModel.formatTime(viewModel.weather!.sunset, viewModel.weather!.timezone),
                      ),
                      InfoGridTile(
                        title: 'Feels Like',
                        icon: Icons.thermostat,
                        value: '${viewModel.weather!.feelsLike.toStringAsFixed(1)}°C',
                      ),
                      InfoGridTile(
                        title: 'Visibility',
                        icon: Icons.remove_red_eye,
                        value: '${(viewModel.weather!.visibility / 1000).toStringAsFixed(1)} km',
                      ),
                    ],
                  ),
                ] else if (viewModel.errorMessage != null)
                  Center(
                    child: Text(
                      viewModel.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Center(
                    child: Text(
                      'Search for a city to get weather',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final String dateTime;

  const WeatherCard({super.key, required this.weather, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              weather.city,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(dateTime, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Image.network(
              'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
              width: 80,
              height: 80,
            ),
            Text(
              "${weather.temperature}°C",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Text(
              weather.description.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WeatherDetail(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: "${weather.humidity}%",
                ),
                WeatherDetail(
                  icon: Icons.air,
                  label: 'Wind',
                  value: "${weather.windSpeed} m/s",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetail({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).iconTheme.color),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class InfoGridTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;

  const InfoGridTile({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).iconTheme.color),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
