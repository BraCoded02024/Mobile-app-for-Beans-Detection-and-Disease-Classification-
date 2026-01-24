# Example Detection Result Output

## Scenario 1: Image IS a Bean Crop

```dart
Map<String, dynamic> result = {
  'isBeanCrop': true,
  'plantDetectorConfidence': '94.32',
  'beanClass': 'Diseased',
  'beanConfidence': '87.65',
  'message': 'Bean crop detected and classified',
}
```

**UI Display:**
```
Detection Result
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stage 1: Plant Detector
Bean Crop: Yes
Confidence: 94.32%

Stage 2: Bean Classification
Class: Diseased
Confidence: 87.65%
```

**Scan Card:**
- Title: "Diseased"
- Status Badge: "Bean Crop" (green)
- Confidence: "87.65%"

---

## Scenario 2: Image is NOT a Bean Crop

```dart
Map<String, dynamic> result = {
  'isBeanCrop': false,
  'plantDetectorConfidence': '78.54',
  'message': 'Not a bean crop',
}
```

**UI Display:**
```
Detection Result
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stage 1: Plant Detector
Bean Crop: No
Confidence: 78.54%

(Stage 2 skipped - not a bean crop)
```

**Scan Card:**
- Title: "Analyzing..."
- Status Badge: "Not Bean" (orange)
- No Stage 2 results

---

## Bean Class Examples (Update as needed)

Currently defined in `model_service.dart` line 92:
```dart
final beanClasses = ['Healthy', 'Diseased', 'Angular Leaf Spot', 'Bean Rust', 'Unknown'];
```

These correspond to model output indices:
- Index 0: Healthy
- Index 1: Diseased
- Index 2: Angular Leaf Spot
- Index 3: Bean Rust
- Index 4: Unknown

**You must update this list to match your actual model's output classes!**

---

## Error Examples

### Model Not Found Error
```
Detection failed: Failed to load models: No such file or directory
```
**Solution:** Ensure models are in `assets/models/` folder in pubspec.yaml

### Image Decode Error
```
Detection failed: Failed to decode image
```
**Solution:** Image file is corrupted or unsupported format (use JPG/PNG)

### Inference Error
```
Plant detector error: Invalid tensor shape
```
**Solution:** Model input/output shapes don't match. Update reshape values in model_service.dart

---

## Testing Checklist

- [ ] Models load without errors on app startup
- [ ] Gallery image picker works
- [ ] Camera capture works
- [ ] Rotating GIF shows during analysis
- [ ] Stage 1 detection completes
- [ ] Stage 2 only runs if Stage 1 says it's a bean crop
- [ ] Confidence scores display correctly
- [ ] Scan cards show in history
- [ ] Error messages display when something fails
- [ ] GIF stops when detection completes


