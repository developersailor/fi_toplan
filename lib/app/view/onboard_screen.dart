import 'package:fi_toplan/app/view/gathering_area_list_view.dart';
import 'package:flutter/material.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          _buildPage(
            context,
            'Toplanma Alanlarına Hoş Geldiniz',
            'En yakın toplanma alanını kolayca bulun.',
            Icons.map,
          ),
          _buildPage(
            context,
            "Bursa'daki Toplanma Alanları",
            "Bursa'daki toplanma alanlarını keşfedin.",
            Icons.location_city,
          ),
          _buildPage(
            context,
            'Yol Tarifi',
            'En yakın toplanma alanına yol tarifi alın.',
            Icons.directions,
          ),
          _buildPage(
            context,
            'Başlayalım',
            'Hadi başlayalım!',
            Icons.arrow_forward,
            isLastPage: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    String title,
    String description,
    IconData icon, {
    bool isLastPage = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          if (isLastPage)
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<GatheringAreaListView>(
                    builder: (context) => const GatheringAreaListView(),
                  ),
                );
              },
              child: const Text('Başlayalım'),
            ),
        ],
      ),
    );
  }
}
