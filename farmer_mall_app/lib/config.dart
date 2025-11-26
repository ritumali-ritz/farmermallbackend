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
  // UPDATE THIS IP WHEN YOU CHANGE NETWORKS!
  // ============================================
  static const String serverIP = '10.91.17.111'; // Change this!
  static const int serverPort = 5000;
  
  // Base URL for API calls
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$serverPort';
    } else {
      return 'http://$serverIP:$serverPort';
    }
  }
  
  // Socket.IO URL for real-time features
  static String get socketUrl {
    if (kIsWeb) {
      return 'http://localhost:$serverPort';
    } else {
      return 'http://$serverIP:$serverPort';
    }
  }
}

