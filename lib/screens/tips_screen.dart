import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/agricultural_knowledge_service.dart';
import '../theme/app_colors.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _weatherAdvice;
  bool _isLoadingWeather = true;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWeatherAndAdvice();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherAndAdvice() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final weather = await _weatherService.getCurrentWeather(
        position.latitude, 
        position.longitude
      );
      
      setState(() {
        _currentWeather = weather;
        _weatherAdvice = AgriculturalKnowledgeService.getWeatherAdvice(
          weather['weather'][0]['main']
        );
        _isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        _weatherError = 'Unable to load weather data: $e';
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text(
          'Agricultural Guide',
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.gold,
          tabs: const [
            Tab(icon: Icon(Icons.wb_sunny), text: 'Weather'),
            Tab(icon: Icon(Icons.healing), text: 'Diseases'),
            Tab(icon: Icon(Icons.agriculture), text: 'Farming'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Seasonal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeatherTab(),
          _buildDiseasesTab(),
          _buildFarmingTab(),
          _buildSeasonalTab(),
        ],
      ),
    );
  }

  Widget _buildWeatherTab() {
    if (_isLoadingWeather) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    if (_weatherError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _weatherError!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWeatherAndAdvice,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentWeatherCard(),
          const SizedBox(height: 20),
          _buildRealTimeAdviceCard(),
          const SizedBox(height: 20),
          _buildAgriculturalNewsCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    if (_currentWeather == null) return const SizedBox();

    final temp = _currentWeather!['main']['temp'].round();
    final description = _currentWeather!['weather'][0]['description'];
    final humidity = _currentWeather!['main']['humidity'];
    final windSpeed = _currentWeather!['wind']['speed'];

    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.gold),
                const SizedBox(width: 8),
                const Text(
                  'Current Weather',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${temp}°C',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Humidity: $humidity% • Wind: ${windSpeed}m/s',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeAdviceCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: AgriculturalKnowledgeService.getWeatherBasedAdvice(
        latitude: 7.3362, // Default to Ghana coordinates, should use actual location
        longitude: -2.3375,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            color: Color(0xFF2A2A2A),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Card(
            color: const Color(0xFF2A2A2A),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to load real-time advice: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final adviceData = snapshot.data!;
        final advice = adviceData['advice'];
        
        return Card(
          color: const Color(0xFF2A2A2A),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: AppColors.gold),
                    const SizedBox(width: 8),
                    const Text(
                      'Real-Time Agricultural Advice',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Source: ${adviceData['source']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                
                if (advice['recommendations'] != null) ...[
                  const Text(
                    'Current Recommendations:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(advice['recommendations'] as List<String>).map(
                    (recommendation) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: AppColors.gold)),
                          Expanded(
                            child: Text(
                              recommendation,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getDiseaseRiskColor(advice['disease_risk']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getDiseaseRiskColor(advice['disease_risk']).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: _getDiseaseRiskColor(advice['disease_risk']),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Disease Risk: ${advice['disease_risk']?.toString().toUpperCase() ?? 'Unknown'}',
                        style: TextStyle(
                          color: _getDiseaseRiskColor(advice['disease_risk']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                Text(
                  'Last updated: ${DateTime.now().toString().substring(0, 16)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgriculturalNewsCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AgriculturalKnowledgeService.getAgriculturalNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            color: Color(0xFF2A2A2A),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox();
        }

        final news = snapshot.data!;
        
        return Card(
          color: const Color(0xFF2A2A2A),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.newspaper, color: AppColors.gold),
                    SizedBox(width: 8),
                    Text(
                      'Agricultural Alerts & News',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...news.take(3).map((item) => _buildNewsItem(item)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsItem(Map<String, dynamic> newsItem) {
    Color priorityColor = newsItem['priority'] == 'high' 
        ? Colors.red 
        : newsItem['priority'] == 'medium' 
            ? Colors.orange 
            : Colors.green;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: priorityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  newsItem['priority']?.toString().toUpperCase() ?? 'INFO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  newsItem['title'] ?? 'Agricultural Update',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            newsItem['summary'] ?? 'No summary available',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Source: ${newsItem['source'] ?? 'Unknown'}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getDiseaseRiskColor(String? risk) {
    switch (risk?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDiseasesTab() {
    final diseases = ['Angular Leaf Spot', 'Bean Rust', 'Healthy'];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diseases.length,
      itemBuilder: (context, index) {
        final disease = diseases[index];
        
        return FutureBuilder<Map<String, dynamic>>(
          future: AgriculturalKnowledgeService.getDiseaseManagementAdvice(disease),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Card(
                color: const Color(0xFF2A2A2A),
                margin: const EdgeInsets.only(bottom: 16),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Card(
                color: const Color(0xFF2A2A2A),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error loading $disease information',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            final diseaseData = snapshot.data!;
            final diseaseInfo = diseaseData['disease_info'];
            
            if (diseaseInfo == null) return const SizedBox();
            
            return Card(
              color: const Color(0xFF2A2A2A),
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                leading: Text(
                  disease == 'Angular Leaf Spot' ? '🍃' : 
                  disease == 'Bean Rust' ? '🦠' : '✅',
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  disease,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (diseaseInfo['scientific_name'] != null)
                      Text(
                        diseaseInfo['scientific_name'],
                        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Source: ${diseaseData['source'] ?? 'Agricultural Extension'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (diseaseData['references'] != null)
                      Text(
                        'References: ${(diseaseData['references'] as List).join(', ')}',
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (diseaseInfo['symptoms'] != null) ...[
                          _buildSectionTitle('Symptoms'),
                          _buildBulletList(diseaseInfo['symptoms']),
                          const SizedBox(height: 16),
                        ],
                        if (diseaseInfo['favorable_conditions'] != null) ...[
                          _buildSectionTitle('Favorable Conditions'),
                          _buildBulletList(diseaseInfo['favorable_conditions']),
                          const SizedBox(height: 16),
                        ],
                        if (diseaseInfo['management'] != null) ...[
                          _buildSectionTitle('Management'),
                          _buildBulletList(diseaseInfo['management']),
                          const SizedBox(height: 16),
                        ],
                        if (diseaseInfo['organic_solutions'] != null) ...[
                          _buildSectionTitle('Organic Solutions'),
                          _buildBulletList(diseaseInfo['organic_solutions']),
                          const SizedBox(height: 16),
                        ],
                        if (diseaseInfo['best_practices'] != null) ...[
                          _buildSectionTitle('Best Practices'),
                          _buildBulletList(diseaseInfo['best_practices']),
                        ],
                        
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data Reliability: HIGH',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last updated: ${diseaseInfo['last_updated'] ?? 'Recently'}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFarmingTab() {
    final growthStages = AgriculturalKnowledgeService.getAllGrowthStageTips();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: growthStages.length,
      itemBuilder: (context, index) {
        final stage = growthStages.keys.elementAt(index);
        final stageInfo = growthStages[stage]!;
        
        return Card(
          color: const Color(0xFF2A2A2A),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      stageInfo['icon'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stageInfo['title'],
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBulletList(stageInfo['tips']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeasonalTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: AgriculturalKnowledgeService.getSeasonalRecommendations(
        latitude: 7.3362, // Default to Ghana coordinates, should use actual location
        longitude: -2.3375,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Error loading seasonal data: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final seasonalData = snapshot.data!;
        final recommendations = seasonalData['recommendations'] as List<Map<String, dynamic>>;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recommendations.length + 1, // +1 for header card
          itemBuilder: (context, index) {
            if (index == 0) {
              // Header card with location and season info
              return Card(
                color: const Color(0xFF2A2A2A),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.gold),
                          SizedBox(width: 8),
                          Text(
                            'Seasonal Agricultural Calendar',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hemisphere: ${seasonalData['hemisphere']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Current Month: ${_getMonthName(seasonalData['month'])}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Source: ${seasonalData['source']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        'Reliability: ${seasonalData['reliability']}',
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            final recommendation = recommendations[index - 1];
            
            return Card(
              color: const Color(0xFF2A2A2A),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          recommendation['icon'] ?? '📅',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recommendation['title'] ?? 'Seasonal Advice',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (recommendation['timing'] != null)
                                Text(
                                  recommendation['timing'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(recommendation['priority']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recommendation['priority']?.toString().toUpperCase() ?? 'INFO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBulletList(recommendation['recommendations'] ?? []),
                    const SizedBox(height: 12),
                    Text(
                      'Source: ${recommendation['source'] ?? 'Agricultural Extension'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: AppColors.gold)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }
}

