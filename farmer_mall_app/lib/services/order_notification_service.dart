import 'package:flutter/material.dart';
import 'package:farmer_mall_app/services/socket_service.dart';
import 'package:farmer_mall_app/services/notification_service.dart';
import 'package:farmer_mall_app/services/storage_service.dart';
import 'package:farmer_mall_app/screens/farmer_orders_screen.dart';
import 'dart:async';

class OrderNotificationService {
  static final SocketService _socketService = SocketService();
  static bool _listening = false;
  static BuildContext? _context;

  // Initialize order notification listener
  static Future<void> initialize(BuildContext? context) async {
    _context = context;
    
    if (_listening) return;
    
    final user = await StorageService.getMap('current_user');
    if (user == null || user['role'] != 'farmer') {
      return; // Only farmers receive order notifications
    }

    final farmerId = user['id'];
    if (farmerId == null) return;

    // Connect to Socket.IO
    await _socketService.connect();
    
    // Join with user ID
    _socketService.socket?.emit('join', farmerId);

    // Listen for order notifications
    _socketService.socket?.on('order_notification_$farmerId', (data) {
      if (data is Map) {
        _handleOrderNotification(Map<String, dynamic>.from(data));
      }
    });

    _listening = true;
  }

  // Handle incoming order notification
  static void _handleOrderNotification(Map<String, dynamic> data) {
    final order = data['order'] as Map<String, dynamic>? ?? {};
    final message = data['message'] as String? ?? 'New order received';
    final orderId = order['id'] ?? 0;

    // Show system notification (works when app is closed)
    NotificationService.showOrderNotification(
      title: 'New Order Received! 🎉',
      body: message,
      orderId: orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0,
    );

    // Show in-app notification (overlay)
    if (_context != null) {
      NotificationService.showInAppNotification(
        title: 'New Order!',
        message: message,
        context: _context,
        onTap: () {
          // Navigate to orders screen
          if (_context != null) {
            Navigator.of(_context!).push(
              MaterialPageRoute(
                builder: (_) => const FarmerOrdersScreen(),
              ),
            );
          }
        },
      );

      // Show dialog notification (only if app is in foreground)
      // Don't show dialog if app is in background - system notification is enough
      if (_context != null && Navigator.of(_context!).canPop() == false) {
        // App is in foreground, show dialog
        NotificationService.showOrderDialog(
          context: _context!,
          title: 'New Order Received!',
          message: message,
          orderData: order,
          onViewOrder: () {
            Navigator.of(_context!).push(
              MaterialPageRoute(
                builder: (_) => const FarmerOrdersScreen(),
              ),
            );
          },
        );
      }
    }
  }

  // Stop listening
  static void stopListening() {
    _socketService.socket?.off('order_notification_${_socketService.socket?.id}');
    _listening = false;
  }

  // Dispose
  static void dispose() {
    stopListening();
    _context = null;
  }
}

