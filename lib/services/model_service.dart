import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ModelService {
  late Interpreter _plantDetectorInterpreter;
  late Interpreter _beanDensenetInterpreter;
  bool _isInitialized = false;
  
  // Configurable threshold - can be adjusted based on real-world performance
  double _beanDetectionThreshold = 0.35; // Start with a more balanced threshold

  Future<void> initializeModels() async {
    if (_isInitialized) return;
    try {
      _plantDetectorInterpreter = await Interpreter.fromAsset('assets/models/plant_detector.tflite');
      _beanDensenetInterpreter = await Interpreter.fromAsset('assets/models/bean_densenet121.tflite');
      _isInitialized = true;
      print('Models loaded successfully');
    } catch (e) {
      throw Exception('Failed to load models: $e');
    }
  }

  // Method to adjust threshold based on real-world testing
  void setBeanDetectionThreshold(double threshold) {
    _beanDetectionThreshold = threshold;
    print('Bean detection threshold updated to: $threshold');
  }

  double get currentThreshold => _beanDetectionThreshold;

  Future<Map<String, dynamic>> runDetectionPipeline(img.Image image) async {
    if (!_isInitialized) await initializeModels();

    try {
      // Stage 1: Plant Detector
      final plantDetectorResult = _runPlantDetector(image);
      final double rawValue = plantDetectorResult['raw'];
      
      print('DEBUG: Plant Detector Raw Score: $rawValue');

      // ADAPTIVE THRESHOLD: Balanced approach based on real-world testing
      // 35% threshold provides better balance between sensitivity and specificity
      bool isBean = rawValue > _beanDetectionThreshold;
      
      // Enhanced confidence levels for better user understanding
      String confidenceLevel;
      String recommendation = '';
      
      if (rawValue > 0.6) {
        confidenceLevel = 'Very High confidence';
        recommendation = 'Definitely a bean crop';
      } else if (rawValue > 0.45) {
        confidenceLevel = 'High confidence';
        recommendation = 'Likely a bean crop';
      } else if (rawValue > 0.35) {
        confidenceLevel = 'Medium confidence';
        recommendation = 'Possibly a bean crop';
      } else if (rawValue > _beanDetectionThreshold) {
        confidenceLevel = 'Low confidence';
        recommendation = 'Uncertain - may be bean crop';
      } else {
        confidenceLevel = 'Very low confidence';
        recommendation = 'Likely not a bean crop';
      }

      if (!isBean) {
        return {
          'isBeanCrop': false,
          'message': '$recommendation',
          'plantDetectorConfidence': (rawValue * 100).toStringAsFixed(1),
          'raw': rawValue,
          'confidenceLevel': confidenceLevel,
          'recommendation': recommendation,
        };
      }

      // Stage 2: Bean Classification
      final beanResult = _runBeanDensenet(image);
      return {
        'isBeanCrop': true,
        'plantDetectorConfidence': (rawValue * 100).toStringAsFixed(1),
        'beanClass': beanResult['class'],
        'beanConfidence': beanResult['confidence'],
        'message': '$recommendation - ${beanResult['class']} detected',
        'confidenceLevel': confidenceLevel,
        'recommendation': recommendation,
      };
    } catch (e) {
      throw Exception('Detection pipeline error: $e');
    }
  }

  Map<String, dynamic> _runPlantDetector(img.Image image) {
    final resized = img.copyResize(image, width: 224, height: 224);
    final input = _preprocess(resized);
    var output = List.filled(1, 0.0).reshape([1, 1]);
    _plantDetectorInterpreter.run(input, output);
    return {'raw': (output[0][0] as num).toDouble()};
  }

  Map<String, dynamic> _runBeanDensenet(img.Image image) {
    final resized = img.copyResize(image, width: 224, height: 224);
    final input = _preprocess(resized);
    var output = List.filled(3, 0.0).reshape([1, 3]);
    _beanDensenetInterpreter.run(input, output);
    
    final List<dynamic> results = output[0];
    int maxIdx = 0;
    double maxVal = -1.0;
    for (int i = 0; i < results.length; i++) {
      double val = (results[i] as num).toDouble();
      if (val > maxVal) {
        maxVal = val;
        maxIdx = i;
      }
    }

    final labels = ['Angular Leaf Spot', 'Bean Rust', 'Healthy'];
    return {
      'class': labels[maxIdx],
      'confidence': (maxVal * 100).toStringAsFixed(1),
    };
  }

  // Enhanced preprocessing with better normalization
  List<dynamic> _preprocess(img.Image image) {
    // Ensure proper color format
    final processedImage = img.copyResize(image, width: 224, height: 224);
    
    var flatList = List<double>.filled(224 * 224 * 3, 0.0);
    int index = 0;
    
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = processedImage.getPixel(x, y);
        
        // Extract RGB values (0-255 range)
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();
        
        // Normalize to [-1, 1] range (zero-centered)
        flatList[index++] = (r - 127.5) / 127.5;
        flatList[index++] = (g - 127.5) / 127.5;
        flatList[index++] = (b - 127.5) / 127.5;
      }
    }
    
    return flatList.reshape([1, 224, 224, 3]);
  }

  void dispose() {
    _plantDetectorInterpreter.close();
    _beanDensenetInterpreter.close();
  }
}
