import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_product_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/product.dart';
import '../theme.dart';
import 'product_detail_screen.dart';
import 'subscription_management_screen.dart';
import 'farmer_orders_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);
  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  bool loading = true;
  List<Map<String, dynamic>> myProducts = [];

  @override
  void initState() {
    super.initState();
    loadMyProducts();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> loadMyProducts({bool showLoader = true}) async {
    if (showLoader) {
      setState(() => loading = true);
    }
    final user = await StorageService.getMap('current_user');
    final farmerId = user?['id'] ?? 1; // Fallback to 1 for demo
    final res = await ApiService.get('/farmer/myProducts/$farmerId');
    if (!mounted) return;
    final body = res['body'];
    if (body is List) {
      setState(() {
        loading = false;
        myProducts = body.whereType<Map<String, dynamic>>().toList();
      });
    } else {
      setState(() => loading = false);
      _showMessage('Failed to load your products');
    }
  }

  Future<void> deleteProduct(int productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => loading = true);
    final res = await ApiService.delete('/farmer/deleteProduct/$productId');
    if (!mounted) return;
    setState(() => loading = false);

    if (res['statusCode'] == 200) {
      _showMessage('Product deleted successfully');
      loadMyProducts();
    } else {
      final msg = res['body'] is Map && res['body']['message'] != null
          ? res['body']['message']
          : 'Failed to delete product';
      _showMessage(msg);
    }
  }

  String _getImageUrl(String? imageUrl) {
    return ApiService.resolveMediaUrl(imageUrl) ?? '';
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()),
            ),
            tooltip: 'My Orders',
          ),
          IconButton(
            icon: const Icon(Icons.subscriptions),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionManagementScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => loadMyProducts(),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => loadMyProducts(showLoader: false),
              child: myProducts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No products yet', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('Tap + to add your first product', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: myProducts.length,
                      itemBuilder: (ctx, i) {
                        final p = myProducts[i];
                        final product = Product.fromMap(p);
                        final imageUrl = _getImageUrl(p['image_url']);
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(product: product),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey[200],
                                              child: const Center(child: CircularProgressIndicator()),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p['name'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${(() {
                                            final raw = p['price'];
                                            final v = raw is num
                                                ? raw.toDouble()
                                                : double.tryParse('$raw') ?? 0.0;
                                            return v.toStringAsFixed(2);
                                          })()}',
                                          style: const TextStyle(
                                            color: kAccentOrange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            const Icon(Icons.inventory_2, size: 12, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${p['quantity'] ?? 0} available',
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteProduct(product.id),
                                  tooltip: 'Delete product',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ).then((_) => loadMyProducts()),
      ),
    );
  }
}
