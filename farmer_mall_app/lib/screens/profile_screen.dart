import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';
import 'farmer_dashboard.dart';
import 'cart_screen.dart';
import 'daily_services_screen.dart';
import 'chat_list_screen.dart';
import 'farmer_orders_screen.dart';
import 'buyer_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userData = await StorageService.getMap('current_user');
    setState(() {
      user = userData;
      loading = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kError),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearToken();
      await StorageService.remove('current_user');
      
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ProductListScreen()),
        (route) => false,
      );
      _showMessage('Logged out successfully');
    }
  }

  Future<void> _editAddress() async {
    if (user == null) return;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _AddressDialog(
        initialValue: user!['address']?.toString() ?? '',
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      await _updateAddress(result.trim());
    }
  }

  Future<void> _updateAddress(String newAddress) async {
    if (user == null) return;
    final res = await ApiService.put('/auth/address/${user!['id']}', {
      'address': newAddress,
    });
    final code = res['statusCode'];
    if (code == 200) {
      setState(() {
        user = {...?user, 'address': newAddress};
      });
      await StorageService.setMap('current_user', user!);
      _showMessage('Address updated');
    } else {
      final body = res['body'];
      final msg = body is Map && body['message'] != null
          ? body['message'].toString()
          : 'Failed to update address';
      _showMessage(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFECFDF5),
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: Colors.transparent,
          ),
          body: loading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_outline, size: 80, color: Colors.grey),
                        const SizedBox(height: 24),
                        const Text(
                          'Not Logged In',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Login to access your profile and manage your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                            if (result == true) {
                              loadUserData();
                            }
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Login'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: kPrimaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                user!['name']?[0].toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                      
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kPrimaryGreen.withOpacity(0.1),
                            child: const Icon(Icons.location_on_outlined, color: kPrimaryGreen),
                          ),
                          title: const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              (user!['address'] != null && user!['address'].toString().trim().isNotEmpty)
                                  ? user!['address']
                                  : 'No address added yet',
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: _editAddress,
                            child: Text(
                              (user!['address'] != null && user!['address'].toString().trim().isNotEmpty)
                                  ? 'Edit'
                                  : 'Add',
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                            Text(
                              user!['name'] ?? 'User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user!['email'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            if (user!['phone'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.phone, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    user!['phone'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user!['role']?.toUpperCase() ?? 'USER',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Menu Items
                      if (user!['role'] == 'farmer') ...[
                        _MenuTile(
                          icon: Icons.store,
                          title: 'My Products',
                          subtitle: 'Manage your products',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FarmerDashboard()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _MenuTile(
                          icon: Icons.shopping_bag,
                          title: 'My Orders',
                          subtitle: 'View and manage orders',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      _MenuTile(
                        icon: Icons.shopping_cart,
                        title: 'My Cart',
                        subtitle: 'View your cart',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      _MenuTile(
                        icon: Icons.shopping_bag_outlined,
                        title: 'My Orders',
                        subtitle: 'View your orders',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BuyerOrdersScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      _MenuTile(
                        icon: Icons.subscriptions,
                        title: 'My Subscriptions',
                        subtitle: 'Manage subscriptions',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DailyServicesScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      _MenuTile(
                        icon: Icons.chat,
                        title: 'Messages',
                        subtitle: 'View your messages',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatListScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: logout,
                          icon: const Icon(Icons.logout, color: kError),
                          label: const Text(
                            'Logout',
                            style: TextStyle(color: kError, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: kError, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                ),
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryGreen.withOpacity(0.1),
          child: Icon(icon, color: kPrimaryGreen),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _AddressDialog extends StatefulWidget {
  final String initialValue;

  const _AddressDialog({required this.initialValue});

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Address'),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Delivery Address',
          hintText: 'House / Street / City / PIN',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

