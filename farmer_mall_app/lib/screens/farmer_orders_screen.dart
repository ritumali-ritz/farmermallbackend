import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool loading = true;
  String filterStatus =
      'all'; // all, pending, confirmed, shipped, delivered, cancelled

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> loadOrders() async {
    final user = await StorageService.getMap('current_user');
    if (user == null || user['id'] == null) {
      setState(() {
        loading = false;
        orders = [];
      });
      return;
    }

    setState(() => loading = true);
    final res = await ApiService.get('/order/farmer/${user['id']}');
    if (!mounted) return;

    if (res['statusCode'] == 200 && res['body'] is List) {
      final allOrders = (res['body'] as List).cast<Map<String, dynamic>>();
      setState(() {
        orders = filterStatus == 'all'
            ? allOrders
            : allOrders
                .where((o) => _parseString(o['order_status']) == filterStatus)
                .toList();
        loading = false;
      });
    } else {
      setState(() => loading = false);
      _showMessage('Failed to load orders');
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    setState(() => loading = true);
    final res = await ApiService.put('/order/updateStatus/$orderId', {
      'order_status': newStatus,
    });
    if (!mounted) return;
    setState(() => loading = false);

    if (res['statusCode'] == 200) {
      _showMessage('Order status updated successfully');
      loadOrders();
    } else {
      final msg = res['body'] is Map && res['body']['message'] != null
          ? res['body']['message']
          : 'Failed to update order status';
      _showMessage(msg);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    return status?.toUpperCase() ?? 'UNKNOWN';
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(int orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentStatus == 'pending')
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.blue),
                title: const Text('Confirm Order'),
                onTap: () {
                  Navigator.pop(context);
                  updateOrderStatus(orderId, 'confirmed');
                },
              ),
            if (currentStatus == 'confirmed' || currentStatus == 'pending')
              ListTile(
                leading: const Icon(Icons.local_shipping, color: Colors.purple),
                title: const Text('Mark as Shipped'),
                onTap: () {
                  Navigator.pop(context);
                  updateOrderStatus(orderId, 'shipped');
                },
              ),
            if (currentStatus == 'shipped')
              ListTile(
                leading:
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                title: const Text('Mark as Delivered'),
                onTap: () {
                  Navigator.pop(context);
                  updateOrderStatus(orderId, 'delivered');
                },
              ),
            if (currentStatus != 'cancelled' && currentStatus != 'delivered')
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel Order'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmCancel(orderId);
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(int orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              updateOrderStatus(orderId, 'cancelled');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _getImageUrl(String? imageUrl) {
    return ApiService.resolveMediaUrl(imageUrl) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadOrders,
          ),
        ],
      ),
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
        child: Column(
          children: [
            // Filter chips
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildFilterChip('all', 'All'),
                  _buildFilterChip('pending', 'Pending'),
                  _buildFilterChip('confirmed', 'Confirmed'),
                  _buildFilterChip('shipped', 'Shipped'),
                  _buildFilterChip('delivered', 'Delivered'),
                  _buildFilterChip('cancelled', 'Cancelled'),
                ],
              ),
            ),
            // Orders list
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No orders found',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // Product image
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: _getImageUrl(
                                                        order['image_url'])
                                                    .isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: _getImageUrl(
                                                        order['image_url']),
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                          Icons.image),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.grey[200],
                                                    child:
                                                        const Icon(Icons.image),
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  order['product_name'] ??
                                                      'Product',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Buyer: ${order['buyer_name'] ?? 'Unknown'}',
                                                  style: TextStyle(
                                                      color: Colors.grey[700]),
                                                ),
                                                if (order['buyer_phone'] !=
                                                    null)
                                                  Text(
                                                    'Phone: ${order['buyer_phone']}',
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          _buildStatusChip(_parseString(
                                              order['order_status'])),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Quantity: ${_parseInt(order['quantity'])}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Amount: ₹${_parseDouble(order['total_amount']).toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: kAccentOrange,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_parseString(
                                                      order['order_status']) !=
                                                  'cancelled' &&
                                              _parseString(
                                                      order['order_status']) !=
                                                  'delivered')
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  _showStatusUpdateDialog(
                                                _parseInt(order['id']),
                                                _parseString(
                                                    order['order_status']),
                                              ),
                                              icon: const Icon(Icons.edit,
                                                  size: 18),
                                              label: const Text('Update'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: kPrimaryGreen,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (order['buyer_address'] != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Delivery Address: ${order['buyer_address']}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to safely parse values from database
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _parseString(dynamic value) {
    if (value == null) return 'pending';
    if (value is String) return value;
    return value.toString();
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = filterStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            filterStatus = status;
          });
          loadOrders();
        },
        selectedColor: kPrimaryGreen.withOpacity(0.3),
        checkmarkColor: kPrimaryGreen,
      ),
    );
  }
}
