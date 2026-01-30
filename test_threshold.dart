// Quick test to verify the threshold changes work
import 'lib/services/model_service.dart';

void main() {
  final modelService = ModelService();
  
  print('Initial threshold: ${modelService.currentThreshold}');
  
  // Test threshold adjustment
  modelService.setBeanDetectionThreshold(0.3);
  print('Updated threshold: ${modelService.currentThreshold}');
  
  // Test different thresholds
  final testScores = [0.298, 0.336, 0.45, 0.65, 0.85];
  
  for (double score in testScores) {
    bool wouldDetect = score > modelService.currentThreshold;
    print('Score: ${(score * 100).toStringAsFixed(1)}% - Would detect: $wouldDetect');
  }
}