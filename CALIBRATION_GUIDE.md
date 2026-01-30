# Bean Detection Calibration Guide

## What is Calibration?

Calibration is about finding the **sweet spot** between:
- **Sensitivity**: Catching real bean crops (avoiding false negatives)
- **Specificity**: Rejecting non-bean crops (avoiding false positives)

## The Trade-off Problem

Your concern is absolutely valid! Here's what happens at different thresholds:

### High Threshold (60-80%)
- ✅ **Pros**: Very few false positives (non-beans won't be detected as beans)
- ❌ **Cons**: May miss real bean crops (like your 29.8% and 33.6% images)
- **Use when**: You want to be very sure detected crops are beans

### Medium Threshold (35-50%) - **RECOMMENDED**
- ✅ **Pros**: Good balance between catching beans and avoiding false positives
- ⚖️ **Balanced**: Some false positives, but catches most real beans
- **Use when**: You want the best overall performance

### Low Threshold (20-35%)
- ✅ **Pros**: Catches almost all bean crops
- ❌ **Cons**: More false positives (non-beans detected as beans)
- **Use when**: It's critical not to miss any bean crops

## How to Find Your Optimal Threshold

### Step 1: Collect Test Images
Gather 10-20 images of each:
- ✅ **Confirmed bean crops** (various conditions, angles, lighting)
- ❌ **Confirmed non-bean plants** (corn, tomato, weeds, etc.)

### Step 2: Test Different Thresholds
1. Start with 35% (our recommended default)
2. Test all your images
3. Record results:
   - How many beans were correctly detected?
   - How many non-beans were falsely detected?

### Step 3: Adjust Based on Results

**If you get too many false positives:**
- Increase threshold to 40-50%
- Test again

**If you miss too many real beans:**
- Decrease threshold to 25-30%
- Test again

### Step 4: Consider Your Use Case

**For Research/Documentation:**
- Use higher threshold (50-60%)
- Better to miss some beans than have false data

**For Field Screening:**
- Use lower threshold (25-35%)
- Better to check a few false positives than miss diseased crops

**For General Use:**
- Use balanced threshold (35-45%)
- Good compromise for most situations

## Current Solution

I've set the default to **35%** because:
- Your bean images (29.8%, 33.6%) will be detected
- It's not so low that everything gets detected as beans
- You can easily adjust up or down based on your testing

## Using the Calibration Screen

1. **Tap the tune icon** in the app header
2. **Adjust the slider** to test different thresholds
3. **Watch the color coding**:
   - 🟢 Green: Balanced, recommended range
   - 🟠 Orange: Sensitive, more false positives expected
   - 🔴 Red: Very sensitive, many false positives likely
4. **Test with images** using the "Test with Image" button
5. **Apply** when you find the right balance

## Pro Tips

1. **Test in batches**: Don't adjust based on one image
2. **Consider lighting**: Outdoor vs indoor images may need different thresholds
3. **Document your choice**: Note what threshold works best for your conditions
4. **Seasonal adjustment**: You might need to adjust for different growing seasons
5. **Start conservative**: Begin with 35% and adjust down if needed

## Expected Results with 35% Threshold

Your original bean images:
- 29.8% score → ❌ Still rejected (just below threshold)
- 33.6% score → ✅ Detected as bean crop

If you need both detected, try 28-30% threshold, but monitor for false positives.

## Monitoring Performance

Keep track of:
- **True Positives**: Beans correctly identified as beans
- **False Positives**: Non-beans incorrectly identified as beans  
- **False Negatives**: Beans incorrectly identified as non-beans
- **True Negatives**: Non-beans correctly identified as non-beans

The goal is to maximize true positives and true negatives while minimizing false positives and false negatives.