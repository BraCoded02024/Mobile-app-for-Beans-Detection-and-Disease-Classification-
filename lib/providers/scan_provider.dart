import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import '../services/model_service.dart';
import '../models/scan.dart';
import '../models/scan_filter.dart';

class ScanProvider with ChangeNotifier {
  final ModelService _modelService = ModelService();
  final ImagePicker _imagePicker = ImagePicker();

  List<Scan> _scans = [];
  ScanFilter _filter = ScanFilter.all;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastDetectionResult;

  List<Scan> get allScans => _scans;
  
  // This is what the UI should use to display the list
  List<Scan> get filteredScans {
    if (_filter == ScanFilter.beanCrop) {
      return _scans.where((s) => s.isBeanCrop == true).toList();
    } else if (_filter == ScanFilter.notBean) {
      return _scans.where((s) => s.isBeanCrop == false).toList();
    }
    return [..._scans];
  }

  ScanFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastDetectionResult => _lastDetectionResult;
  
  // Expose model service for calibration
  ModelService get modelService => _modelService;

  Future<void> initializeModels() async {
    try {
      await _modelService.initializeModels();
    } catch (e) {
      _errorMessage = 'Failed to initialize models: $e';
      notifyListeners();
    }
  }

  Future<void> uploadImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await _processImage(pickedFile.path);
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  Future<void> uploadImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        await _processImage(pickedFile.path);
      }
    } catch (e) {
      _errorMessage = 'Failed to capture image: $e';
      notifyListeners();
    }
  }

  Future<void> _processImage(String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    _lastDetectionResult = null;
    notifyListeners();

    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Run detection pipeline
      final result = await _modelService.runDetectionPipeline(image);
      _lastDetectionResult = result;

      // Create scan record
      final newScan = Scan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        timestamp: DateTime.now(),
        isBeanCrop: result['isBeanCrop'] ?? false,
        plantDetectorConfidence: result['plantDetectorConfidence']?.toString(),
        beanClass: result['beanClass'],
        beanConfidence: result['beanConfidence']?.toString(),
      );

      _scans.insert(0, newScan);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Detection failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(ScanFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _modelService.dispose();
    super.dispose();
  }
}
