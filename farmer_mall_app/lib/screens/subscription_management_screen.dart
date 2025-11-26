import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  List<Map<String, dynamic>> subscriptions = [];
  bool loading = true;
  String filterStatus = 'all';

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
    final res = await ApiService.get('/subscription/farmer/${user['id']}');
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

  Future<void> updateSubscriptionStatus(
      int subscriptionId, String status) async {
    final res = await ApiService.post('/subscription/update/$subscriptionId', {
      'status': status,
    });

    if (res['statusCode'] == 200) {
      _showMessage('Subscription updated');
      fetchSubscriptions();
    } else {
      _showMessage('Failed to update subscription');
    }
  }

  List<Map<String, dynamic>> get filteredSubscriptions {
    if (filterStatus == 'all') return subscriptions;
    return subscriptions.where((s) => s['status'] == filterStatus).toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchSubscriptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: filterStatus == 'all',
                  onSelected: () => setState(() => filterStatus = 'all'),
                ),
                _FilterChip(
                  label: 'Active',
                  selected: filterStatus == 'active',
                  onSelected: () => setState(() => filterStatus = 'active'),
                ),
                _FilterChip(
                  label: 'Paused',
                  selected: filterStatus == 'paused',
                  onSelected: () => setState(() => filterStatus = 'paused'),
                ),
                _FilterChip(
                  label: 'Cancelled',
                  selected: filterStatus == 'cancelled',
                  onSelected: () => setState(() => filterStatus = 'cancelled'),
                ),
              ],
            ),
          ),
          const Divider(),
          // Subscriptions list
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredSubscriptions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.subscriptions_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No subscriptions found',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 18)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchSubscriptions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredSubscriptions.length,
                          itemBuilder: (ctx, i) {
                            final sub = filteredSubscriptions[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: getStatusColor(sub['status'])
                                      .withOpacity(0.2),
                                  child: Icon(
                                    sub['status'] == 'active'
                                        ? Icons.check_circle
                                        : Icons.pause_circle,
                                    color: getStatusColor(sub['status']),
                                  ),
                                ),
                                title:
                                    Text(sub['buyer_name'] ?? 'Unknown Buyer'),
                                subtitle: Text(
                                  '${sub['service_type']} - ${sub['quantity']} ${sub['frequency']}',
                                ),
                                trailing: Chip(
                                  label: Text(
                                    sub['status'].toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                  backgroundColor:
                                      getStatusColor(sub['status']),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _InfoRow('Service Type',
                                            sub['service_type']),
                                        _InfoRow('Product',
                                            sub['product_name'] ?? 'N/A'),
                                        _InfoRow(
                                            'Quantity', '${sub['quantity']}'),
                                        _InfoRow('Frequency', sub['frequency']),
                                        _InfoRow(
                                            'Start Date', sub['start_date']),
                                        if (sub['end_date'] != null)
                                          _InfoRow('End Date', sub['end_date']),
                                        _InfoRow('Buyer Email',
                                            sub['buyer_email'] ?? 'N/A'),
                                        if (sub['buyer_phone'] != null)
                                          _InfoRow('Buyer Phone',
                                              sub['buyer_phone']),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            if (sub['status'] == 'active')
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    updateSubscriptionStatus(
                                                        sub['id'], 'paused'),
                                                icon: const Icon(Icons.pause),
                                                label: const Text('Pause'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              ),
                                            if (sub['status'] == 'paused')
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    updateSubscriptionStatus(
                                                        sub['id'], 'active'),
                                                icon: const Icon(
                                                    Icons.play_arrow),
                                                label: const Text('Resume'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                              ),
                                            if (sub['status'] != 'cancelled')
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    updateSubscriptionStatus(
                                                        sub['id'], 'cancelled'),
                                                icon: const Icon(Icons.cancel),
                                                label: const Text('Cancel'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: kPrimaryGreen.withOpacity(0.2),
        checkmarkColor: kPrimaryGreen,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
