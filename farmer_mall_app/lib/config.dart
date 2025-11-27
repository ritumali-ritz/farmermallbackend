import 'package:flutter/foundation.dart';

/// App Configuration
/// 
/// IMPORTANT: When you change networks (different WiFi/hotspot),
/// update the serverIP below with your new IP address.
/// 
/// To get your IP address:
/// 1. Run: node get_local_ip.js (from project root)
/// 2. Or check: ipconfig (Windows) / ifconfig (Mac/Linux)
/// 3. Look for IPv4 address (usually 192.168.x.x or 10.x.x.x)
class AppConfig {
  // ============================================
  // Environment toggles
  // ============================================
  static const bool isProduction = true; // Use Render backend
  static const bool useHttps = true;

  // Render deployment URL (no protocol)
  static const String productionServerURL = 'farmermallbackend.onrender.com';

  // Local development fallback
  static const String serverIP = '10.91.17.111'; // Update when network changes
  static const int serverPort = 5000;
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$serverPort';
    }

    if (isProduction) {
      return useHttps
          ? 'https://$productionServerURL'
          : 'http://$productionServerURL';
    }

    return 'http://$serverIP:$serverPort';
  }
  
  static String get socketUrl {
    if (kIsWeb) {
      return 'http://localhost:$serverPort';
    }

    if (isProduction) {
      return useHttps
          ? 'https://$productionServerURL'
          : 'http://$productionServerURL';
    }

    return 'http://$serverIP:$serverPort';
  }
}

