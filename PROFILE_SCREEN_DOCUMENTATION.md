# Profile Screen Documentation

## Overview
A comprehensive profile screen that displays user information, group details, and project information for the Bean Disease Detection System final year project.

## Features

### 🔐 **User Information Section**
- **User Avatar**: Displays Firebase user photo or default icon
- **Display Name**: Shows the logged-in user's name
- **Email Address**: Shows the user's email with an elegant design
- **Authentication Integration**: Pulls data from Firebase Auth

### 👥 **Group 20B Members Section**
Complete information about all group members:

| Index Number | Name | Role |
|-------------|------|------|
| UEB3227322 | PEPRAH Isaac | Team Lead & ML Engineer |
| UEB3225322 | ASARE Ebenezer | Backend Developer |
| UEB3223022 | KLEMEH Dominic | Frontend Developer |
| UEB3216822 | YUSSIF Hakim | UI/UX Designer |
| UEB3217722 | OSEI Isaac | Quality Assurance |

### 📱 **Project Information**
- **Project Title**: Bean Disease Detection System
- **Course**: Computer Science Final Year Project
- **Description**: AI-powered mobile application for real-time bean crop disease detection
- **Statistics**: ML Models (2), Diseases (3), Accuracy (95%)

### 🏫 **University Information**
- **Institution**: University of Energy and Natural Resources
- **Department**: Computer Science Department
- **Year**: 2026
- **Group**: 20B

### 📋 **Application Details**
- **Version**: 1.0.0
- **Build**: Release
- **Platform**: Flutter
- **Development Year**: 2026

## Design Features

### 🎨 **Visual Design**
- **Dark Theme**: Consistent with app's agricultural theme
- **Gold Accents**: Using AppColors.gold (#D4AF37) for highlights
- **Card-Based Layout**: Clean, organized sections
- **Rounded Corners**: Modern, friendly appearance
- **Shadow Effects**: Depth and visual hierarchy

### 📱 **User Experience**
- **Scrollable Content**: Accommodates all information comfortably
- **Back Navigation**: Easy return to main screen
- **Group Badge**: "Group 20B" identifier in header
- **Member Cards**: Individual cards for each team member
- **Role Indicators**: Clear role identification for each member
- **Avatar System**: Initials-based avatars for members without photos

### 🔧 **Technical Implementation**
- **Firebase Integration**: Real-time user data from authentication
- **Responsive Design**: Adapts to different screen sizes
- **Asset Management**: Supports member profile photos
- **Navigation Integration**: Seamless integration with bottom navigation

## Navigation Integration

### **Bottom Navigation Update**
- **Index 3**: Profile icon (Icons.person_outline) now navigates to ProfileScreen
- **Navigation Method**: Push navigation with MaterialPageRoute
- **Back Button**: Integrated back navigation in profile header

### **Navigation Flow**
```
Homepage → Bottom Nav (Person Icon) → Profile Screen → Back Button → Homepage
```

## File Structure

### **Main File**
- `lib/screens/profile_screen.dart` - Complete profile screen implementation

### **Dependencies**
- `firebase_auth` - User authentication data
- `app_colors.dart` - Consistent color theming
- Material Design components

### **Assets**
- `lib/assets/profile/Peprah_Isaac.jpeg` - Team lead profile photo
- Default avatar system for other members

## Member Information Display

### **Card Layout for Each Member**
```
[Avatar] [Name]           [CS Badge]
         [Role]
         [Index Number]
```

### **Avatar System**
- **With Photo**: Displays actual profile image
- **Without Photo**: Shows initials in colored circle
- **Fallback**: Consistent gold-themed placeholder

### **Information Hierarchy**
1. **Name** - Primary identification (white, bold)
2. **Role** - Secondary information (gold, medium)
3. **Index Number** - Tertiary information (grey, small)

## Responsive Features

### **Screen Adaptation**
- **Scrollable Content**: Handles various screen heights
- **Flexible Layout**: Adapts to different screen widths
- **Safe Area**: Respects device notches and navigation bars
- **Bottom Spacing**: Accounts for bottom navigation bar

### **Interactive Elements**
- **Back Button**: Smooth navigation return
- **Scrolling**: Smooth scroll behavior
- **Touch Feedback**: Appropriate button responses

## Future Enhancements

### **Potential Additions**
- **Edit Profile**: Allow users to update their information
- **Contact Information**: Add email/phone for team members
- **Social Links**: GitHub, LinkedIn profiles for members
- **Project Gallery**: Screenshots and project highlights
- **Achievement Badges**: Academic or project milestones
- **Export Feature**: Share group information

### **Technical Improvements**
- **Caching**: Cache user data for offline viewing
- **Animation**: Smooth transitions and micro-interactions
- **Localization**: Multi-language support
- **Accessibility**: Enhanced screen reader support

## Usage Instructions

### **For Users**
1. Tap the person icon (👤) in the bottom navigation
2. View your profile information at the top
3. Scroll down to see group member details
4. Review project and application information
5. Use the back button to return to the main screen

### **For Developers**
1. Profile data is automatically populated from Firebase Auth
2. Group member data is stored as static constants
3. Easy to update member information by modifying the `groupMembers` list
4. Consistent theming through AppColors class
5. Modular design allows easy feature additions

This profile screen serves as both a user information center and a comprehensive team showcase, perfect for demonstrating the collaborative nature of your final year project.