import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {

List<String> allCities = [
  // Major Indian cities
  'Delhi',
  'Mumbai',
  'Bengaluru',
  'Hyderabad',
  'Chennai',
  'Kolkata',
  'Ahmedabad',
  'Pune',
  'Jaipur',
  'Surat',
  'Lucknow',
  'Kanpur',
  'Nagpur',
  'Indore',
  'Thane',
  'Bhopal',
  'Visakhapatnam',
  'Patna',
  'Vadodara',
  'Ghaziabad',
  'Ludhiana',
  'Agra',
  'Nashik',
  'Faridabad',
  'Meerut',
  'Rajkot',
  'Varanasi',
  'Amritsar',
  'Ranchi',
  'Guwahati',
  'Chandigarh',
  'Jodhpur',
  'Coimbatore',
  'Vijayawada',
  'Mysuru',
  'Madurai',
  'Raipur',
  'Dehradun',
  'Noida',
  'Jabalpur',
  'Gwalior',
  'Kochi',
  'Trivandrum',
  'Bhubaneshwar',
  'Jamshedpur',
  'Udaipur',
  'Haridwar',
  'Shimla',
  'Manali',
  'Mangalore',

  // Haryana districts
  'Ambala',
  'Bhiwani',
  'Charkhi Dadri',
  'Faridabad',
  'Fatehabad',
  'Gurugram',
  'Hisar',
  'Jhajjar',
  'Jind',
  'Kaithal',
  'Karnal',
  'Kurukshetra',
  'Mahendragarh',
  'Nuh',
  'Palwal',
  'Panchkula',
  'Panipat',
  'Rewari',
  'Rohtak',
  'Sirsa',
  'Sonipat',
  'Yamunanagar',
];
List<String> filteredCities = [];
  final TextEditingController _cityController = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _weatherData = null;
    });

    const apiKey = '105423fbdd8f398a18bd5d80ca642ec8';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final int timezoneOffset = data['timezone']; // in seconds
        setState(() {
          _weatherData = data;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('City not found.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error fetching weather.')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
String getFormattedDate(int timezoneOffset) {
  final nowUtc = DateTime.now().toUtc();
  final cityTime = nowUtc.add(Duration(seconds: timezoneOffset));
  return DateFormat.yMMMMEEEEd().add_jm().format(cityTime);
}
  // String getFormattedDate() {
  //   return DateFormat.yMMMMEEEEd().add_jm().format(DateTime.now());
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple Gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           TextField(
  controller: _cityController,
  style: const TextStyle(color: Colors.black),
  decoration: InputDecoration(
    hintText: 'Enter city',
    hintStyle: const TextStyle(color: Colors.blueGrey),
    filled: true,
    fillColor: Colors.white.withOpacity(0.85),
    prefixIcon: const Icon(Icons.search, color: Colors.black),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  onChanged: (value) {
    setState(() {
      filteredCities = allCities
          .where((city) =>
              city.toLowerCase().startsWith(value.toLowerCase()))
          .toList();
    });
  },
  onSubmitted: (value) {
    fetchWeather(value);
    setState(() => filteredCities = []);
  },
),
            if (filteredCities.isNotEmpty)
  Container(
    margin: const EdgeInsets.only(top: 8),
    height: 150,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListView.builder(
      itemCount: filteredCities.length,
      itemBuilder: (context, index) {
        return ListTile(
         title: Text(
  filteredCities[index],
  style: const TextStyle(color: Colors.black), // Set text color to black
),
          onTap: () {
            _cityController.text = filteredCities[index];
            fetchWeather(filteredCities[index]);
            setState(() => filteredCities = []);
          },
        );
      },
    ),
  ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => fetchWeather(_cityController.text),
              icon: const Icon(Icons.search),
              label: const Text('Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : _weatherData != null
                ? WeatherCard(
  data: _weatherData!,
  dateTime: getFormattedDate(_weatherData!['timezone']),
)
                : Center(
                  child: const Text(
                    'Search for a city to get weather',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String dateTime;

  const WeatherCard({super.key, required this.data, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final weather = data['weather'][0];
    final main = data['main'];
    final wind = data['wind'];

    return Card(
      color: Colors.white.withOpacity(0.9), // Keep card readable
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              data['name'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A0DAD), // Purple text
              ),
            ),
            Text(dateTime, style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 10),
            Image.network(
              'https://openweathermap.org/img/wn/${weather['icon']}@2x.png',
              width: 80,
              height: 80,
            ),
            Text(
              "${main['temp']}°C",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              weather['description'].toString().toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WeatherDetail(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: "${main['humidity']}%",
                ),
                WeatherDetail(
                  icon: Icons.air,
                  label: 'Wind',
                  value: "${wind['speed']} m/s",
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
