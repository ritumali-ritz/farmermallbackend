import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/primary_button.dart';
import '../theme.dart';
import 'login_screen.dart';

class DailyServicesScreen extends StatefulWidget {
  const DailyServicesScreen({Key? key}) : super(key: key);

  @override
  State<DailyServicesScreen> createState() => _DailyServicesScreenState();
}

class _DailyServicesScreenState extends State<DailyServicesScreen> {
  List<Map<String, dynamic>> subscriptions = [];
  bool loading = true;
  String selectedService = 'milk';

  final serviceTypes = [
    {
      'type': 'milk',
      'icon': Icons.local_drink,
      'name': 'Milk',
      'color': Colors.blue
    },
    {
      'type': 'vegetables',
      'icon': Icons.eco,
      'name': 'Vegetables',
      'color': Colors.green
    },
    {
      'type': 'fruits',
      'icon': Icons.apple,
      'name': 'Fruits',
      'color': Colors.red
    },
    {'type': 'eggs', 'icon': Icons.egg, 'name': 'Eggs', 'color': Colors.orange},
    {
      'type': 'other',
      'icon': Icons.more_horiz,
      'name': 'Other',
      'color': Colors.grey
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> fetchSubscriptions() async {
    final user = await StorageService.getMap('current_user');
    if (user == null || user['id'] == null) {
      setState(() {
        loading = false;
        subscriptions = [];
      });
      return;
    }

    setState(() => loading = true);
    final res = await ApiService.get('/subscription/buyer/${user['id']}');
    if (!mounted) return;

    if (res['statusCode'] == 200 && res['body'] is List) {
      setState(() {
        subscriptions = List<Map<String, dynamic>>.from(res['body'] as List);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
        subscriptions = [];
      });
    }
  }

  Future<void> createSubscription(String serviceType) async {
    final user = await StorageService.getMap('current_user');
    if (user == null || user['id'] == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Show subscription dialog
    showDialog(
      context: context,
      builder: (context) => _SubscriptionDialog(
        serviceType: serviceType,
        buyerId: user['id'],
        onSuccess: () {
          fetchSubscriptions();
        },
      ),
    );
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
            title: const Text('Daily Services'),
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              // Service type selector
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemCount: serviceTypes.length,
                  itemBuilder: (ctx, i) {
                    final service = serviceTypes[i];
                    final isSelected = selectedService == service['type'];
                    return GestureDetector(
                      onTap: () => setState(
                          () => selectedService = service['type'] as String),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (service['color'] as Color).withOpacity(0.2)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? service['color'] as Color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              service['icon'] as IconData,
                              color: service['color'] as Color,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              service['name'] as String,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: service['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // Active subscriptions
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : subscriptions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.subscriptions_outlined,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text('No active subscriptions',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18)),
                                const SizedBox(height: 24),
                                PrimaryButton(
                                  label:
                                      'Subscribe to ${serviceTypes.firstWhere((s) => s['type'] == selectedService)['name']}',
                                  onPressed: () =>
                                      createSubscription(selectedService),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: subscriptions.length,
                            itemBuilder: (ctx, i) {
                              final sub = subscriptions[i];
                              final service = serviceTypes.firstWhere(
                                (s) => s['type'] == sub['service_type'],
                                orElse: () => serviceTypes.last,
                              );
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: (service['color'] as Color)
                                        .withOpacity(0.2),
                                    child: Icon(service['icon'] as IconData,
                                        color: service['color'] as Color),
                                  ),
                                  title: Text(sub['product_name'] ??
                                      service['name'] as String),
                                  subtitle: Text(
                                    '${sub['quantity']} ${sub['frequency']} - ${sub['status']}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final res = await ApiService.delete(
                                          '/subscription/${sub['id']}');
                                      if (res['statusCode'] == 200 ||
                                          res['statusCode'] == 204) {
                                        _showMessage('Subscription cancelled');
                                        fetchSubscriptions();
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => createSubscription(selectedService),
            icon: const Icon(Icons.add),
            label: const Text('Subscribe'),
            backgroundColor: kPrimaryGreen,
          ),
        ),
      ),
    );
  }
}

class _SubscriptionDialog extends StatefulWidget {
  final String serviceType;
  final int buyerId;
  final VoidCallback onSuccess;

  const _SubscriptionDialog({
    required this.serviceType,
    required this.buyerId,
    required this.onSuccess,
  });

  @override
  State<_SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<_SubscriptionDialog> {
  final _quantityController = TextEditingController(text: '1');
  String _frequency = 'daily';
  bool _loading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _createSubscription() async {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    setState(() => _loading = true);
    final res = await ApiService.post('/subscription/create', {
      'buyer_id': widget.buyerId,
      'service_type': widget.serviceType,
      'quantity': quantity,
      'frequency': _frequency,
      'start_date': DateTime.now().toIso8601String().split('T')[0],
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['statusCode'] == 201) {
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      final msg = res['body'] is Map && res['body']['message'] != null
          ? res['body']['message']
          : 'Failed to create subscription';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Subscribe to Daily Service'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _frequency,
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: ['daily', 'weekly', 'monthly']
                .map((f) =>
                    DropdownMenuItem(value: f, child: Text(f.toUpperCase())))
                .toList(),
            onChanged: (v) => setState(() => _frequency = v!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _createSubscription,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Subscribe'),
        ),
      ],
    );
  }
}
