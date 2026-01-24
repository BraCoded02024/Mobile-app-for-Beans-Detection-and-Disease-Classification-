import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ModelService {
  late Interpreter _plantDetectorInterpreter;
  late Interpreter _beanDensenetInterpreter;
  bool _isInitialized = false;

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

  Future<Map<String, dynamic>> runDetectionPipeline(img.Image image) async {
    if (!_isInitialized) await initializeModels();

    try {
      // Stage 1: Plant Detector
      final plantDetectorResult = _runPlantDetector(image);
      final double rawValue = plantDetectorResult['raw'];
      
      print('DEBUG: Plant Detector Raw Score: $rawValue');

      // STRICT THRESHOLD: Must be > 0.8 to be a Bean
      bool isBean = rawValue > 0.8;

      if (!isBean) {
        return {
          'isBeanCrop': false,
          'message': 'Not a bean crop',
          'plantDetectorConfidence': (rawValue * 100).toStringAsFixed(1),
          'raw': rawValue,
        };
      }

      // Stage 2: Bean Classification
      final beanResult = _runBeanDensenet(image);
      return {
        'isBeanCrop': true,
        'plantDetectorConfidence': (rawValue * 100).toStringAsFixed(1),
        'beanClass': beanResult['class'],
        'beanConfidence': beanResult['confidence'],
        'message': 'Bean crop detected!',
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

  // Optimized Zero-Centered Normalization [-1, 1]
  List<dynamic> _preprocess(img.Image image) {
    var flatList = List<double>.filled(224 * 224 * 3, 0.0);
    int index = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);
        flatList[index++] = (pixel.r - 127.5) / 127.5;
        flatList[index++] = (pixel.g - 127.5) / 127.5;
        flatList[index++] = (pixel.b - 127.5) / 127.5;
      }
    }
    return flatList.reshape([1, 224, 224, 3]);
  }

  void dispose() {
    _plantDetectorInterpreter.close();
    _beanDensenetInterpreter.close();
  }
}
