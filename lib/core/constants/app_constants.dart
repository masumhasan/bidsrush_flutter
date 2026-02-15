import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // API Endpoints
  // Use environment variable API_BASE_URL to override
  // For Android emulator: use 10.0.2.2
  // For physical device with adb reverse: use localhost
  // For physical device without adb: use your computer's IP address
  static String get apiBaseUrl {
    const envUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    if (envUrl.isNotEmpty) return envUrl;
    
    // Use localhost for Android (works with adb reverse for physical devices)
    // If testing on emulator without adb reverse, change to 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://localhost:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  // Stream.io
  static const String streamApiKey = String.fromEnvironment(
    'STREAM_API_KEY',
    defaultValue: 'eynbkmnv6fjq',
  );

  // Clerk
  static const String clerkPublishableKey = String.fromEnvironment(
    'CLERK_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_YWxpdmUtamFja2FsLTIzLmNsZXJrLmFjY291bnRzLmRldiQ',
  );

  // API Routes
  static const String streamEndpoint = '/stream';
  static const String productsEndpoint = '/products';
  static const String streamTokenEndpoint = '/stream/token';

  // Stream Types
  static const String defaultStreamType = 'default';
  static const String livestreamChatType = 'livestream';

  // Aspect Ratios
  static const double verticalVideoAspectRatio = 9 / 16;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration streamConnectionTimeout = Duration(seconds: 10);
}
