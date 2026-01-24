class Scan {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final bool isBeanCrop;
  final String? plantDetectorConfidence;
  final String? beanClass;
  final String? beanConfidence;

  Scan({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.isBeanCrop,
    this.plantDetectorConfidence,
    this.beanClass,
    this.beanConfidence,
  });
}

