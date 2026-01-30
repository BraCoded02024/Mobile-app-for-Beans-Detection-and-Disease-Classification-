import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../services/model_service.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  double _threshold = 0.25;

  @override
  void initState() {
    super.initState();
    // Get the current threshold from the model service via provider
    Future.microtask(() {
      final provider = context.read<ScanProvider>();
      setState(() {
        _threshold = provider.modelService.currentThreshold;
      });
    });
  }

  String _getThresholdDescription(double threshold) {
    if (threshold >= 0.7) {
      return 'Very Strict: High accuracy, may miss some beans';
    } else if (threshold >= 0.5) {
      return 'Strict: Good accuracy, some beans might be missed';
    } else if (threshold >= 0.35) {
      return 'Balanced: Good compromise between accuracy and detection';
    } else if (threshold >= 0.25) {
      return 'Sensitive: Catches more beans, but more false positives';
    } else {
      return 'Very Sensitive: Catches most beans, many false positives';
    }
  }

  Color _getThresholdColor(double threshold) {
    if (threshold >= 0.5) {
      return Colors.green;
    } else if (threshold >= 0.35) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text(
          'Model Calibration',
          style: TextStyle(color: Color(0xFFE8DDD2)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE8DDD2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bean Detection Threshold',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8DDD2),
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Threshold: ${(_threshold * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFE8DDD2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getThresholdColor(_threshold).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getThresholdColor(_threshold).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getThresholdDescription(_threshold),
                      style: TextStyle(
                        color: _getThresholdColor(_threshold),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Slider(
                    value: _threshold,
                    min: 0.1,
                    max: 0.9,
                    divisions: 80,
                    activeColor: const Color(0xFF463352),
                    inactiveColor: const Color(0xFF463352).withOpacity(0.3),
                    onChanged: (value) {
                      setState(() {
                        _threshold = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '10%\n(Very Sensitive)',
                        style: TextStyle(color: Color(0xFFE8DDD2), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${(_threshold * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Color(0xFF463352),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        '90%\n(Very Strict)',
                        style: TextStyle(color: Color(0xFFE8DDD2), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Understanding the Trade-off:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE8DDD2),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '🎯 Higher Threshold (50-80%):',
                    style: TextStyle(color: Color(0xFFE8DDD2), fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '• Fewer false positives (non-beans won\'t be detected as beans)',
                    style: TextStyle(color: Color(0xFFE8DDD2)),
                  ),
                  Text(
                    '• May miss some real bean crops',
                    style: TextStyle(color: Color(0xFFE8DDD2)),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '⚡ Lower Threshold (20-40%):',
                    style: TextStyle(color: Color(0xFFE8DDD2), fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '• Catches more bean crops',
                    style: TextStyle(color: Color(0xFFE8DDD2)),
                  ),
                  Text(
                    '• More false positives (non-beans detected as beans)',
                    style: TextStyle(color: Color(0xFFE8DDD2)),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '💡 Recommended: Start with 35% and adjust based on your results',
                    style: TextStyle(color: Color(0xFF463352), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF463352),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final provider = context.read<ScanProvider>();
                  provider.modelService.setBeanDetectionThreshold(_threshold);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Threshold updated to ${(_threshold * 100).toStringAsFixed(1)}%',
                      ),
                      backgroundColor: const Color(0xFF463352),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Apply Threshold',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF463352)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.read<ScanProvider>().uploadImageFromGallery();
                },
                child: const Text(
                  'Test with Image',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF463352),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}