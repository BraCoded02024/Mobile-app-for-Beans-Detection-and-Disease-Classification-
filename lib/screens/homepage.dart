import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:group20b/providers/scan_provider.dart';
import 'package:group20b/models/scan.dart';
import 'package:group20b/models/scan_filter.dart';
import 'package:group20b/screens/tips_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    Future.microtask(() async {
      try {
        await context.read<ScanProvider>().initializeModels();
      } catch (e) {
        debugPrint('Model initialization error: $e');
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _showUploadModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<ScanProvider>(
        builder: (context, provider, _) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1F1F1F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Bean Leaf Image',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE8DDD2)),
              ),
              const SizedBox(height: 20),

              if (provider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.white))),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: provider.clearError,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF463352),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: provider.isLoading ? null : () {
                  provider.uploadImageFromGallery();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.image),
                label: const Text('Pick from Gallery', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF463352),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: provider.isLoading ? null : () {
                  provider.uploadImageFromCamera();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF463352) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        icon: Icon(icon, size: 28),
        onPressed: () {
          setState(() => _selectedIndex = index);
          if (index == 2) _showUploadModal();
        },
        color: isSelected ? Colors.white : Colors.white70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF2A2A2A),
      body: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildLandingSection(),
                const SizedBox(height: 25),
                _buildFilterSection(),
                const SizedBox(height: 30),
                _buildScanListSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF463352),
        child: const Icon(Icons.question_answer, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TipsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundImage: AssetImage('lib/assets/logo.png')),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Hello, Farmer!', style: TextStyle(fontSize: 18, color: Color(0xFFB8A89B))),
              Text('Bean Disease Detection', style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Color(0xFFE8DDD2))),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLandingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Container(
            decoration: const BoxDecoration(color: Color(0xFF3A3A3A), borderRadius: BorderRadius.all(Radius.circular(20))),
            child: const TextField(
              style: TextStyle(fontSize: 18, color: Color(0xFFE8DDD2)),
              decoration: InputDecoration(
                hintText: 'Search past scans...',
                hintStyle: TextStyle(color: Color(0xFF8A7F78)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF8A7F78), size: 26),
                suffixIcon: Icon(Icons.mic, color: Color(0xFF463352), size: 26),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            _buildFilterChip('All Scans', ScanFilter.all, provider),
            const SizedBox(width: 15),
            _buildFilterChip('Bean Crops', ScanFilter.beanCrop, provider),
            const SizedBox(width: 15),
            _buildFilterChip('Not Bean', ScanFilter.notBean, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ScanFilter filter, ScanProvider provider) {
    bool isSelected = provider.filter == filter;
    return GestureDetector(
      onTap: () => provider.setFilter(filter),
      child: Container(
        width: 140,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF463352) : const Color(0xFF3A3A3A),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF8A7F78))),
        ),
      ),
    );
  }

  Widget _buildScanListSection() {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        final scans = provider.filteredScans;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text('Recent Scans', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE8DDD2))),
            ),
            const SizedBox(height: 15),

            if (provider.errorMessage != null && !provider.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade900,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: provider.clearError,
                      ),
                    ],
                  ),
                ),
              ),

            if (provider.isLoading)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3A3A3A),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ClipOval(
                          child: Image.asset(
                            'lib/assets/ball.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.image_search, size: 50, color: Color(0xFF8A7F78)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Analyzing image...', style: TextStyle(color: Color(0xFFB8A89B), fontSize: 16)),
                  ],
                ),
              )
            else if (provider.lastDetectionResult != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildDetectionResultCard(provider.lastDetectionResult!),
              )
            else if (scans.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('No scans yet. Upload an image to analyze.', style: TextStyle(color: Color(0xFF8A7F78))),
              ),

            if (scans.isNotEmpty && !provider.isLoading) ...[
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: scans.map((scan) => _buildScanCard(scan)).toList(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDetectionResultCard(Map<String, dynamic> result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detection Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE8DDD2))),
          const SizedBox(height: 15),
          const Text('Stage 1: Plant Detector', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB8A89B))),
          const SizedBox(height: 8),
          Text('Bean Crop: ${result['isBeanCrop'] ? 'Yes' : 'No'}', style: const TextStyle(color: Color(0xFFE8DDD2))),
          if (result['plantDetectorConfidence'] != null)
            Text('Confidence: ${result['plantDetectorConfidence']}%', style: const TextStyle(color: Color(0xFFE8DDD2))),

          if (result['isBeanCrop']) ...[
            const SizedBox(height: 15),
            const Text('Stage 2: Bean Classification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB8A89B))),
            const SizedBox(height: 8),
            Text('Class: ${result['beanClass']}', style: const TextStyle(color: Color(0xFFE8DDD2))),
            if (result['beanConfidence'] != null)
              Text('Confidence: ${result['beanConfidence']}%', style: const TextStyle(color: Color(0xFFE8DDD2))),
          ],
        ],
      ),
    );
  }

  Widget _buildScanCard(Scan scan) {
    return Container(
      width: 260,
      height: 200,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: scan.isBeanCrop ? const Color(0xFF463352) : const Color(0xFF3A3A3A),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Bean Scan', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(scan.beanClass ?? (scan.isBeanCrop ? 'Detected' : 'Not Bean'),
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('MMM dd, yyyy').format(scan.timestamp),
                      style: const TextStyle(color: Colors.white60, fontSize: 14)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: scan.isBeanCrop ? Colors.green[600] : Colors.orange,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(scan.isBeanCrop ? 'Bean Crop' : 'Not Bean', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
              if (scan.beanConfidence != null)
                Text('${scan.beanConfidence}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Container(
        height: 75,
        margin: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
        decoration: BoxDecoration(
          color: const Color(0xFF212121),
          borderRadius: const BorderRadius.all(Radius.circular(35)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, 0),
            _buildNavItem(Icons.history_outlined, 1),
            _buildNavItem(Icons.add, 2),
            _buildNavItem(Icons.person_outline, 3),
            _buildNavItem(Icons.settings_outlined, 4),
          ],
        ),
      ),
    );
  }
}
