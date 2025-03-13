import 'package:fi_toplan/app/view/gathering_area_list_view.dart';
import 'package:flutter/material.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
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
          // Yön okları
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Geri Butonu
                if (_currentPage > 0)
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Icon(Icons.arrow_back),
                  )
                else
                  const SizedBox(width: 40), // Boşluk tutucu
                // Sayfa göstergesi
                Row(
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: _currentPage == index ? 12 : 8,
                      height: _currentPage == index ? 12 : 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index ? Colors.blue : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),

                // İleri Butonu
                if (_currentPage < 3)
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Icon(Icons.arrow_forward),
                  )
                else
                  const SizedBox(width: 40), // Boşluk tutucu
              ],
            ),
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
