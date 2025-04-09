import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whether_app/model/weather_model.dart';
import '../viewmodels/weather_viewmodel.dart';

class WeatherHomePage extends StatelessWidget {
  const WeatherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WeatherViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.purpleAccent,
      resizeToAvoidBottomInset: true, // This helps avoid the overflow issue
      appBar: AppBar(

        centerTitle: true,
        title: const Text('Weather App',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
     body: SafeArea(
  child: GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(), // Tap outside to close keyboard
    child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        const SizedBox(height: 40), // Adds spacing from top
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
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Enter city',
            hintStyle: const TextStyle(color: Colors.blueGrey),
            filled: true,
            fillColor: Colors.white.withOpacity(0.85),
            prefixIcon: const Icon(Icons.search, color: Colors.black),
            suffixIcon: viewModel.isCurrentLocation
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black),
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
            color: Colors.white.withOpacity(0.95),
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
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () {
                  viewModel.cityController.text =
                      viewModel.filteredCities[index];
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
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: viewModel.fetchWeatherFromLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Use Current Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
            ),
          ),
        ],
      ),
    ],
  ),
),

        const SizedBox(height: 30),
        if (viewModel.isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.white))
        else if (viewModel.weather != null) ...[
          WeatherCard(
            weather: viewModel.weather!,
            dateTime: viewModel.getFormattedDate(),
          ),
          const SizedBox(height: 20),
          const Text(
            "More Details",
            style: TextStyle(
              color: Color.fromARGB(255, 109, 6, 6),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
              style: const TextStyle(color: Colors.redAccent, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          )
        else
          const Center(
            child: Text(
              'Search for a city to get weather',
              style: TextStyle(color: Colors.white, fontSize: 21),
              textAlign: TextAlign.center,
            ),
          ),
      ],
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
        color: Colors.grey.shade300, // Light grey background to contrast white cloud icon
      //color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              weather.city,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A0DAD),
              ),
            ),
            Text(dateTime, style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 10),
            Image.network(
              'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
              width: 80,
              height: 80,
            ),
            Text(
              "${weather.temperature}°C",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            Text(
              weather.description.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
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
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
