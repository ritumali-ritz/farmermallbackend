import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool addingToCart = false;
  bool buyingNow = false;
  String get _imageUrl {
    return ApiService.resolveMediaUrl(widget.product.imageUrl) ?? '';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _checkLogin() async {
    final user = await StorageService.getMap('current_user');
    if (user == null || user['id'] == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return result == true;
    }
    return true;
  }

  Future<bool> _ensureAddress() async {
    final user = await StorageService.getMap('current_user');
    final address = user?['address']?.toString().trim() ?? '';
    if (address.isEmpty) {
      _showMessage('Please add your delivery address in your profile');
      return false;
    }
    return true;
  }

  Future<void> _addToCart() async {
    if (!await _checkLogin()) return;

    final user = await StorageService.getMap('current_user');
    if (user == null) return;

    if (quantity > widget.product.quantity) {
      _showMessage('Quantity exceeds available stock');
      return;
    }

    setState(() => addingToCart = true);
    final res = await ApiService.post('/cart/add', {
      'buyer_id': user['id'],
      'product_id': widget.product.id,
      'quantity': quantity,
    });

    if (!mounted) return;
    setState(() => addingToCart = false);

    if (res['statusCode'] == 200 || res['statusCode'] == 201) {
      _showMessage('Added to cart');
    } else {
      final msg = res['body'] is Map && res['body']['message'] != null
          ? res['body']['message']
          : 'Failed to add to cart';
      _showMessage(msg);
    }
  }

  Future<void> _buyNow() async {
    if (!await _checkLogin()) return;
    if (!await _ensureAddress()) return;

    final user = await StorageService.getMap('current_user');
    if (user == null) return;

    if (quantity > widget.product.quantity) {
      _showMessage('Quantity exceeds available stock');
      return;
    }

    // Show payment method dialog (COD only)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Payment Method: Cash on Delivery (COD)'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.money, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pay ₹${(widget.product.price * quantity).toStringAsFixed(2)} when you receive the order',
                      style: TextStyle(color: Colors.green[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _placeOrder();
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
            child: const Text('Place Order (COD)'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    final user = await StorageService.getMap('current_user');
    if (user == null) return;

    setState(() => buyingNow = true);
    final totalAmount = widget.product.price * quantity;
    final res = await ApiService.post('/order/place', {
      'buyer_id': user['id'],
      'product_id': widget.product.id,
      'farmer_id': widget.product.farmerId,
      'quantity': quantity,
      'total_amount': totalAmount,
    });

    if (!mounted) return;
    setState(() => buyingNow = false);

    if (res['statusCode'] == 200 || res['statusCode'] == 201) {
      _showMessage('Order placed successfully!');
      Navigator.pop(context);
    } else {
      final msg = res['body'] is Map && res['body']['message'] != null
          ? res['body']['message']
          : 'Failed to place order';
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
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported,
                                size: 64, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image,
                              size: 100, color: Colors.grey[400]),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${widget.product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: kAccentOrange,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.inventory_2,
                                    size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.product.quantity} in stock',
                                  style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text('Quantity: ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: quantity > 1
                                ? () => setState(() => quantity--)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('$quantity',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: quantity < widget.product.quantity
                                ? () => setState(() => quantity++)
                                : null,
                          ),
                          const Spacer(),
                          Text(
                            'Total: ₹${(widget.product.price * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kAccentOrange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (widget.product.description != null &&
                          widget.product.description!.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description!,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: addingToCart
                            ? null
                            : () async {
                                await _addToCart();
                              },
                        icon: addingToCart
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.shopping_cart),
                        label: const Text('Add to Cart'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: kPrimaryGreen),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final user =
                              await StorageService.getMap('current_user');
                          if (user == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                otherUserId: widget.product.farmerId,
                                otherUserName: 'Farmer',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: kPrimaryGreen),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: buyingNow
                        ? null
                        : () async {
                            await _buyNow();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: buyingNow
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Buy Now',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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
