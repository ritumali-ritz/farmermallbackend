import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/product_list_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  runApp(const FarmerMallApp());
}

class FarmerMallApp extends StatelessWidget {
  const FarmerMallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Mall',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Allow guest browsing - show product list, but prompt login when needed
    // Login state is persisted, so user stays logged in even after app restart
    return const ProductListScreen();
  }
}
