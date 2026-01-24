# 🏗️ System Architecture & Data Flow

## Complete System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     BEAN DETECTION APP                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   main.dart      │
                    │ (App Entry)      │
                    └────────┬─────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
        ┌──────────────┐ ┌──────────┐ ┌──────────────┐
        │Task Provider │ │ScanProvd │ │Scan Model    │
        └──────────────┘ └────┬─────┘ └──────────────┘
                               │
                ┌──────────────┘
                │
                ▼
        ┌─────────────────────┐
        │  ScanProvider       │
        │  (State Manager)    │
        └────────┬────────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
┌───────────┐ ┌────────┐ ┌──────────────┐
│ImagePicker│ │Scans[] │ │Loading State │
└─────┬─────┘ └────────┘ └──────────────┘
      │
      │ (selected image path)
      │
      ▼
┌──────────────────────┐
│  ModelService        │
│  (ML Pipeline)       │
└──────────┬───────────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
┌─────────────────────┐    ┌──────────────────────┐
│ STAGE 1:            │    │ STAGE 2:             │
│ plant_detector.     │───▶│ bean_densenet121.    │
│ tflite              │    │ tflite               │
│                     │    │                      │
│ Input: 224×224 RGB  │    │ Input: 224×224 RGB   │
│ Output: isBeanCrop  │    │ Output: Class +      │
│         Confidence  │    │         Confidence   │
└─────────────────────┘    └──────────────────────┘
                                      │
                                      ▼
                          ┌────────────────────────┐
                          │ Detection Results Map  │
                          │ - isBeanCrop           │
                          │ - Confidence scores    │
                          │ - Class name           │
                          └────────┬───────────────┘
                                   │
                                   ▼
                          ┌────────────────────────┐
                          │ Create Scan Record &   │
                          │ Save to History        │
                          └────────┬───────────────┘
                                   │
                                   ▼
                          ┌────────────────────────┐
                          │ Update UI              │
                          │ - Hide GIF             │
                          │ - Show Results         │
                          │ - Add to Cards         │
                          └────────────────────────┘
```

---

## File Dependency Tree

```
lib/
├── main.dart
│   └── imports: ScanProvider, TaskProvider
│       ├── providers/
│       │   ├── scan_provider.dart
│       │   │   ├── imports: ModelService, Scan, ScanFilter
│       │   │   │   ├── services/
│       │   │   │   │   └── model_service.dart
│       │   │   │   │       └── imports: tflite_flutter, image
│       │   │   │   ├── models/
│       │   │   │   │   ├── scan.dart
│       │   │   │   │   └── scan_filter.dart
│       │   │   │   ├── image_picker (external)
│       │   │   │   └── image (external)
│       │   │   └── dart:io
│       │   └── task_provider.dart
│       └── screens/
│           └── homepage.dart
│               ├── imports: ScanProvider, Scan, ScanFilter
│               ├── imports: intl
│               └── imports: tips_screen
├── models/
│   ├── scan.dart
│   └── scan_filter.dart
├── services/
│   └── model_service.dart
│       ├── imports: tflite_flutter
│       ├── imports: image
│       └── references: assets/models/
├── screens/
│   ├── homepage.dart
│   ├── tips_screen.dart
│   └── ...others
├── assets/
│   ├── rotating_ball.gif
│   ├── logo.png
│   └── ball.jpg
└── providers/
    ├── scan_provider.dart
    └── task_provider.dart

assets/
└── models/
    ├── plant_detector.tflite ← YOU ADD THIS
    └── bean_densenet121.tflite ← YOU ADD THIS
```

---

## Data Flow - Image Detection Pipeline

```
┌──────────────────────────────────────────────────────────┐
│ User selects image from Gallery or Camera                │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │ ScanProvider          │
         │ uploadImageFromGallery│
         │ uploadImageFromCamera │
         └────────────┬──────────┘
                      │
                      ▼
         ┌───────────────────────┐
         │ _processImage()       │
         │ - Read file bytes     │
         │ - Decode image        │
         │ - Set isLoading=true  │
         │ - notify UI           │
         └────────────┬──────────┘
                      │
                      ▼
         ┌───────────────────────┐
         │ ModelService          │
         │ runDetectionPipeline()│
         └────────────┬──────────┘
                      │
          ┌───────────┴────────────┐
          │                        │
          ▼                        ▼
    ┌──────────────────┐   ┌──────────────────┐
    │ _runPlantDetector│   │ Resize image     │
    │ - Resize 224×224 │   │ to 224×224       │
    │ - Normalize      │   │                  │
    │ - Inference      │   │ Normalize values │
    │ - Get output     │   │ (0.0-1.0)        │
    └────────┬─────────┘   └────────┬─────────┘
             │                      │
             └──────────┬───────────┘
                        │
                        ▼
            ┌─────────────────────────┐
            │ Get predictions array   │
            │ Find max confidence     │
            │ isBeanCrop = true/false │
            └────────────┬────────────┘
                         │
               ┌─────────┴─────────┐
               ▼                   ▼
          NOT BEAN            IS BEAN
               │                   │
               ▼                   ▼
          Return result    ┌─────────────────┐
          isBean=false     │_runBeanDensenet │
                           │ - Same process  │
                           │ - Get class     │
                           │ - Get confidence│
                           └────────┬────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ Return full result: │
                         │ - isBeanCrop=true   │
                         │ - beanClass        │
                         │ - Confidences      │
                         └────────┬────────────┘
                                  │
                                  ▼
         ┌────────────────────────────────────┐
         │ Back in _processImage()            │
         │ - Store in _lastDetectionResult    │
         │ - Create Scan record               │
         │ - Add to _scans list               │
         │ - Set isLoading=false              │
         │ - notify UI                        │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌───────────────────────┐
         │ UI Updates:           │
         │ 1. GIF stops rotating │
         │ 2. Results display    │
         │ 3. Scan card appears  │
         │ 4. Data saved         │
         └───────────────────────┘
```

---

## Class Responsibilities

### ModelService
```
Responsibilities:
  ✓ Load TFLite models from assets
  ✓ Manage model instances
  ✓ Preprocess images (resize, normalize)
  ✓ Run Stage 1 detection
  ✓ Run Stage 2 classification
  ✓ Parse model outputs
  ✓ Clean up resources

Methods:
  • initializeModels() - Load models once
  • runDetectionPipeline() - Main pipeline
  • _runPlantDetector() - Stage 1
  • _runBeanDensenet() - Stage 2
  • _imageToByteList() - Preprocessing
  • dispose() - Cleanup
```

### ScanProvider
```
Responsibilities:
  ✓ Manage scan list state
  ✓ Handle image selection
  ✓ Orchestrate detection
  ✓ Manage loading state
  ✓ Handle errors
  ✓ Save scan records
  ✓ Notify UI of changes

Methods:
  • initializeModels() - Init on startup
  • uploadImageFromGallery()
  • uploadImageFromCamera()
  • _processImage() - Orchestrator
  • setFilter() - Filter scans
  • clearError() - Error handling
  • dispose() - Cleanup
```

### Scan (Model)
```
Responsibilities:
  ✓ Store detection results
  ✓ Hold image reference
  ✓ Track timestamps

Properties:
  • id - Unique identifier
  • imagePath - Image location
  • timestamp - When scanned
  • isBeanCrop - Stage 1 result
  • plantDetectorConfidence - Stage 1 score
  • beanClass - Stage 2 result
  • beanConfidence - Stage 2 score
```

---

## State Management Flow

```
┌────────────────────────────────┐
│ ScanProvider Initial State      │
├────────────────────────────────┤
│ _scans: []                     │
│ _filter: ScanFilter.all        │
│ _isLoading: false              │
│ _errorMessage: null            │
│ _lastDetectionResult: null     │
└────────────────────────────────┘
         │
         │ User uploads image
         ▼
┌────────────────────────────────┐
│ State During Processing        │
├────────────────────────────────┤
│ _scans: [...]                  │
│ _filter: ScanFilter.all        │
│ _isLoading: TRUE ✓            │
│ _errorMessage: null            │
│ _lastDetectionResult: null     │
│                                │
│ UI shows: Loading GIF          │
└────────────────────────────────┘
         │
         │ Detection complete
         ▼
┌────────────────────────────────┐
│ State After Detection          │
├────────────────────────────────┤
│ _scans: [..., newScan]         │
│ _filter: ScanFilter.all        │
│ _isLoading: FALSE ✓           │
│ _errorMessage: null            │
│ _lastDetectionResult: {        │
│   isBeanCrop: true/false,      │
│   ...scores & class            │
│ }                              │
│                                │
│ UI shows: Results Card         │
└────────────────────────────────┘
```

---

## Error Handling Flow

```
Detection Process
         │
    ┌────┴────┐
    ▼         ▼
  Success   Error
    │         │
    ▼         ▼
  Update   Catch Exception
  state      │
    │        ▼
    │    Set _errorMessage
    │    Set _isLoading=false
    │    notifyListeners()
    │        │
    └────┬───┘
         │
         ▼
    UI displays:
    - Error message in red box
    - Clear button
    - Retry option available
```

---

## Asset References

```
pubspec.yaml declares:
  - lib/assets/           ← UI images
  - assets/models/        ← ML models

At runtime:
  ModelService loads from:
    'assets/models/plant_detector.tflite'
    'assets/models/bean_densenet121.tflite'
    
  HomePage displays:
    'lib/assets/rotating_ball.gif'
    'lib/assets/logo.png'
```

---

## Complete Request-Response Cycle

```
HTTP REST Style Analogy:

Request:
  POST /detect
  {
    image: File
  }

Processing:
  1. Validate image
  2. Load & preprocess
  3. Stage 1 inference
  4. If positive, Stage 2 inference
  5. Aggregate results

Response:
  {
    isBeanCrop: boolean,
    plantDetectorConfidence: string,
    beanClass?: string,
    beanConfidence?: string,
    message: string
  }

Side Effects:
  - Save Scan record
  - Update UI
  - Cache result
```

This is your complete bean detection system! 🌿

