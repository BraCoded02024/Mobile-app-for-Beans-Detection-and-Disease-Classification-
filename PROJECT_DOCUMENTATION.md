# Bean Disease Detection Mobile Application
## Project Documentation & Technical Report

**Project Name:** Group20B - Bean Disease Detection System  
**Platform:** Cross-platform Mobile Application (Flutter)  
**Target Domain:** Agricultural Technology / Precision Farming  
**Date:** January 2026

---

## 1. PROJECT OVERVIEW

### 1.1 Application Purpose
The Bean Disease Detection application is a mobile-first agricultural technology solution designed to assist farmers in identifying bean crop diseases through on-device machine learning. The application provides real-time, offline disease classification without requiring internet connectivity for core ML functionality.

### 1.2 Target Users
- Farmers and agricultural professionals
- Agricultural extension workers
- Crop consultants
- Research institutions focused on bean cultivation

### 1.3 Key Value Proposition
- **Instant Disease Detection**: Real-time analysis of bean leaf images
- **Offline Capability**: Core ML functionality works without internet
- **User-Friendly Interface**: Designed for farmers with varying technical expertise
- **Comprehensive Tracking**: Historical scan records with confidence metrics

---

## 2. TECHNICAL ARCHITECTURE

### 2.1 Framework & Platform
- **Primary Framework:** Flutter 3.9.2+ (Dart 3.9.2+)
- **Architecture Pattern:** Model-View-Provider (MVP) with layered architecture
- **State Management:** Provider pattern with ChangeNotifier
- **Deployment:** Cross-platform (Android, iOS, Web, Desktop)

### 2.2 Core Technology Stack

#### Frontend Technologies
- **Flutter SDK:** Cross-platform UI framework
- **Provider:** State management (v6.1.5+1)
- **Material Design 3:** UI/UX framework
- **Custom Theming:** Dark theme with agricultural color palette

#### Backend & Services
- **Firebase Core:** Authentication and cloud services (v3.10.1)
- **Firebase Auth:** User authentication (v5.4.1)
- **Cloud Firestore:** Document database (v5.6.2)
- **HTTP Client:** REST API communication (v1.2.0)

#### Machine Learning & AI
- **TensorFlow Lite:** On-device ML inference (v0.12.1)
- **Image Processing:** Advanced image manipulation (v4.0.0)
- **Two-Stage Detection Pipeline:** Custom ML architecture

#### Device Integration
- **Image Picker:** Camera/gallery access (v1.0.0)
- **Geolocator:** GPS location services (v10.1.0)
- **Platform Channels:** Native device integration

---

## 3. MACHINE LEARNING IMPLEMENTATION

### 3.1 Two-Stage Detection Architecture

#### Stage 1: Plant Detector (Binary Classification)
- **Model Type:** Binary classifier (TensorFlow Lite)
- **Input:** 224×224 RGB images
- **Output:** Confidence score (0.0-1.0)
- **Purpose:** Determine if image contains bean crop
- **Threshold:** Configurable (default: 35%)

#### Stage 2: Bean Disease Classifier (Multi-class)
- **Model Type:** DenseNet121-based classifier
- **Input:** 224×224 RGB images (Stage 1 positives only)
- **Output:** 3-class disease classification
- **Classes:**
  1. Angular Leaf Spot (fungal disease)
  2. Bean Rust (fungal disease)  
  3. Healthy (no disease detected)

### 3.2 Image Preprocessing Pipeline
```
Raw Image → Resize (224×224) → Normalize [-1,1] → Reshape [1,224,224,3] → TFLite Inference
```

### 3.3 Model Performance Features
- **Adaptive Thresholding:** User-configurable sensitivity
- **Confidence Scoring:** Multi-level confidence reporting
- **Real-time Processing:** Optimized for mobile devices
- **Error Handling:** Robust exception management

---

## 4. APPLICATION FEATURES

### 4.1 Core Functionality

#### Disease Detection System
- **Image Capture:** Camera integration and gallery selection
- **Real-time Analysis:** On-device ML processing with loading animations
- **Results Display:** Confidence scores, disease classification, and recommendations
- **Historical Tracking:** Chronological scan history with filtering options

#### User Interface Features
- **Intuitive Design:** Farmer-friendly interface with clear visual feedback
- **Dark Theme:** Optimized for outdoor use and battery conservation
- **Responsive Layout:** Adaptive design for various screen sizes
- **Accessibility:** High contrast colors and readable fonts

#### Advanced Features
- **Model Calibration:** User-adjustable detection thresholds
- **Weather Integration:** OpenWeatherMap API integration
- **Chat Assistant:** AWS-backed agricultural advice system
- **Educational Content:** Tips and best practices for farmers

### 4.2 Supporting Services

#### Authentication System
- **Firebase Authentication:** Secure user registration and login
- **User Profiles:** Personalized experience and data management
- **Session Management:** Persistent login with secure token handling

#### Data Management
- **Local Storage:** Scan history and user preferences
- **Cloud Sync:** Optional cloud backup via Firebase
- **Export Capabilities:** Data export for record-keeping

#### External Integrations
- **Weather API:** Real-time weather data for agricultural context
- **Location Services:** GPS-based weather and regional recommendations
- **Chat Backend:** AWS server integration for farmer support

---

## 5. TECHNICAL SPECIFICATIONS

### 5.1 Performance Metrics
- **Model Loading Time:** < 3 seconds on average mobile device
- **Inference Time:** < 2 seconds per image analysis
- **Memory Usage:** Optimized for devices with 2GB+ RAM
- **Battery Impact:** Minimal due to efficient TFLite implementation

### 5.2 Device Requirements
- **Minimum OS:** Android 6.0+ / iOS 12.0+
- **RAM:** 2GB minimum, 4GB recommended
- **Storage:** 100MB for app + models
- **Camera:** Required for image capture functionality
- **Internet:** Optional (required only for weather, chat, and authentication)

### 5.3 Security & Privacy
- **Data Privacy:** Images processed locally, not transmitted
- **Authentication:** Firebase secure authentication
- **Permissions:** Camera, location (optional), storage access
- **Compliance:** GDPR-ready data handling practices

---

## 6. DEVELOPMENT STATUS

### 6.1 Completed Features ✅
- [x] Two-stage ML detection pipeline
- [x] Image capture and processing
- [x] User authentication system
- [x] Scan history and filtering
- [x] Weather integration
- [x] Chat assistant integration
- [x] Model calibration system
- [x] Responsive UI/UX design
- [x] Error handling and validation

### 6.2 Current Capabilities
- **Functional ML Pipeline:** Both detection stages operational
- **Production-Ready UI:** Complete user interface implementation
- **Cross-Platform Deployment:** Ready for Android/iOS release
- **Offline Functionality:** Core features work without internet
- **User Testing Ready:** Suitable for field testing and validation

### 6.3 Quality Assurance
- **Code Quality:** Modular architecture with separation of concerns
- **Error Handling:** Comprehensive exception management
- **Performance Optimization:** Efficient memory and battery usage
- **User Experience:** Intuitive design tested for agricultural use cases

---

## 7. DEPLOYMENT & DISTRIBUTION

### 7.1 Build Configuration
- **Android:** APK/AAB generation ready
- **iOS:** App Store deployment configured
- **Web:** Progressive Web App (PWA) capable
- **Desktop:** Windows/macOS/Linux support available

### 7.2 Asset Management
- **ML Models:** Bundled in app assets (plant_detector.tflite, bean_densenet121.tflite)
- **Images & Icons:** Optimized for various screen densities
- **Fonts & Themes:** Custom agricultural-themed design system

---

## 8. FUTURE ENHANCEMENTS

### 8.1 Potential Improvements
- **Additional Crop Support:** Extend to other crop types
- **Enhanced ML Models:** Improved accuracy through retraining
- **Offline Maps:** GPS-based field mapping
- **Data Analytics:** Farming insights and trend analysis
- **Multi-language Support:** Localization for different regions

### 8.2 Scalability Considerations
- **Cloud ML:** Optional cloud-based model updates
- **Data Synchronization:** Multi-device sync capabilities
- **Enterprise Features:** Bulk processing and reporting tools

---

## 9. TECHNICAL ACHIEVEMENTS

### 9.1 Innovation Highlights
- **Adaptive Thresholding:** User-configurable ML sensitivity
- **Two-Stage Architecture:** Efficient false-positive reduction
- **Offline-First Design:** Core functionality without internet dependency
- **Agricultural UX:** Farmer-centric interface design

### 9.2 Problem-Solving Approach
- **Threshold Optimization:** Solved false negative issues through calibration
- **Performance Optimization:** Efficient on-device ML processing
- **User Experience:** Intuitive design for non-technical users
- **Cross-Platform Compatibility:** Single codebase for multiple platforms

---

## 10. CONCLUSION

The Bean Disease Detection application represents a complete, production-ready agricultural technology solution. The application successfully combines advanced machine learning capabilities with user-friendly mobile interface design, creating a practical tool for farmers to identify and manage bean crop diseases.

**Key Strengths:**
- Robust two-stage ML architecture with configurable sensitivity
- Complete cross-platform mobile application
- Offline-capable core functionality
- Production-ready codebase with comprehensive error handling
- User-centric design optimized for agricultural use cases

**Technical Readiness:**
The application is ready for field testing, user validation, and production deployment across Android and iOS platforms.

---

**Prepared by:** Development Team  
**Review Date:** January 2026  
**Status:** Production Ready