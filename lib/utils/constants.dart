import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'ArvyaX Yoga';
  static const String appVersion = '1.0.0';

  // Asset Paths
  static const String posesJsonPath = 'assets/poses.json';
  static const String imagesPath = 'assets/images/';
  static const String audioPath = 'assets/audio/';
  static const String musicPath = 'assets/music/';

  // Timing
  static const int defaultPoseDuration = 30;
  static const int countdownDuration = 5;

  // UI Constants
  static const double defaultPadding = 20.0;
  static const double borderRadius = 15.0;
  static const double cardElevation = 5.0;
}

class AppStrings {
  static const String startSession = 'Start Session';
  static const String pauseSession = 'Pause';
  static const String resumeSession = 'Resume';
  static const String sessionComplete = 'Session Complete!';
  static const String congratulations = 'Congratulations! You\'ve completed your yoga session.';
  static const String finish = 'Finish';
  static const String loading = 'Loading...';
  static const String errorLoading = 'Error loading session';
}