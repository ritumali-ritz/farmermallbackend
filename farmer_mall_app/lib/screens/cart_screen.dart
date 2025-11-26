import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/primary_button.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import '../models/product.dart';
import 'profile_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool loading = true;
  double totalAmount = 0;
  String? deliveryAddress;

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cart when screen is focused
    fetchCart();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> fetchCart() async {
    final user = await StorageService.getMap('current_user');
    if (user == null || user['id'] == null) {
      setState(() {
        loading = false;
        cartItems = [];
        deliveryAddress = null;
      });
      return;
    }

    setState(() {
      loading = true;
      deliveryAddress = user['address']?.toString();
    });
    final res = await ApiService.get('/cart/${user['id']}');
    if (!mounted) return;

    if (res['statusCode'] == 200 && res['body'] is List) {
      final items = List<Map<String, dynamic>>.from(res['body'] as List);
      double total = 0;
      for (var item in items) {
        final rawPrice = item['price'];
        final rawQty = item['quantity'];
        final price = rawPrice is num
            ? rawPrice.toDouble()
            : double.tryParse('$rawPrice') ?? 0.0;
        final qty = rawQty is num ? rawQty.toInt() : int.tryParse('$rawQty') ?? 0;
        total += price * qty;
      }
      setState(() {
        cartItems = items;
        totalAmount = total;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
        cartItems = [];
      });
    }
  }

  Future<void> updateQuantity(int cartId, int newQuantity) async {
    if (newQuantity < 1) {
      await removeItem(cartId);
      return;
    }

    final res = await ApiService.post('/cart/update', {
      'cart_id': cartId,
      'quantity': newQuantity,
    });

    if (res['statusCode'] == 200) {
      fetchCart();
    } else {
      _showMessage('Failed to update quantity');
    }
  }

  Future<void> removeItem(int cartId) async {
    final res = await ApiService.delete('/cart/remove/$cartId');
    if (res['statusCode'] == 200 || res['statusCode'] == 204) {
      fetchCart();
      _showMessage('Item removed');
    } else {
      _showMessage('Failed to remove item');
    }
  }

  Future<void> checkout() async {
    if (deliveryAddress == null || deliveryAddress!.trim().isEmpty) {
      _showMessage('Please add your delivery address in Profile');
      return;
    }
    final user = await StorageService.getMap('current_user');
    if (user == null || user['id'] == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (cartItems.isEmpty) {
      _showMessage('Cart is empty');
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
                      'Pay ₹${totalAmount.toStringAsFixed(2)} when you receive the order',
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
              await placeOrder();
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
            child: const Text('Place Order (COD)'),
          ),
        ],
      ),
    );
  }

  Future<void> placeOrder() async {
    final user = await StorageService.getMap('current_user');
    if (user == null) return;

    setState(() => loading = true);
    final cartItemsData = cartItems.map((item) => {
      'product_id': item['product_id'],
      'quantity': item['quantity'],
    }).toList();

    final res = await ApiService.post('/order/placeFromCart', {
      'buyer_id': user['id'],
      'cart_items': cartItemsData,
    });

    if (!mounted) return;
    setState(() => loading = false);

    if (res['statusCode'] == 201) {
      _showMessage('Order placed successfully!');
      fetchCart();
    } else {
      final msg = res['body'] is Map && res['body']['message'] != null
          ? res['body']['message']
          : 'Failed to place order';
      _showMessage(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = cartItems.isNotEmpty;

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
            title: const Text('Shopping Cart'),
            actions: [
              if (hasItems)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final user = await StorageService.getMap('current_user');
                    if (user != null && user['id'] != null) {
                      await ApiService.delete('/cart/clear/${user['id']}');
                      await fetchCart();
                    }
                  },
                ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kPrimaryGreen.withOpacity(0.1),
                            child: const Icon(Icons.location_on_outlined, color: kPrimaryGreen),
                          ),
                          title: const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              (deliveryAddress != null && deliveryAddress!.trim().isNotEmpty)
                                  ? deliveryAddress!
                                  : 'No address added yet',
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              );
                              fetchCart();
                            },
                            child: Text(
                              (deliveryAddress != null && deliveryAddress!.trim().isNotEmpty)
                                  ? 'Edit'
                                  : 'Add',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: hasItems
                          ? ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: cartItems.length,
                              itemBuilder: (ctx, i) {
                                final item = cartItems[i];
                                final rawPrice = item['price'];
                                final rawQty = item['quantity'];
                                final price = rawPrice is num
                                    ? rawPrice.toDouble()
                                    : double.tryParse('$rawPrice') ?? 0.0;
                                final quantity = rawQty is num
                                    ? rawQty.toInt()
                                    : int.tryParse('$rawQty') ?? 0;
                                final imageUrl = ApiService.resolveMediaUrl(item['image_url']?.toString());

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            final product = Product(
                                              id: item['product_id'],
                                              name: item['name'],
                                              price: price,
                                              quantity: item['available_quantity'],
                                              description: '',
                                              farmerId: item['farmer_id'] ?? 0,
                                              imageUrl: item['image_url']?.toString(),
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ProductDetailScreen(product: product),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.grey[200],
                                            ),
                                            child: imageUrl != null
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : const Icon(Icons.image, color: Colors.grey),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '₹${price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: kAccentOrange,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.remove_circle_outline),
                                                    onPressed: () => updateQuantity(item['id'], quantity - 1),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                                    child: Text(
                                                      '$quantity',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.add_circle_outline),
                                                    onPressed: () => updateQuantity(item['id'], quantity + 1),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '₹${(price * quantity).toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => removeItem(item['id']),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('Your cart is empty', style: TextStyle(color: Colors.grey, fontSize: 18)),
                                  SizedBox(height: 8),
                                  Text('Add products to get started', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                    ),
                    if (hasItems)
                      Container(
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: kAccentOrange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: 'Proceed to Checkout',
                              onPressed: checkout,
                              loading: loading,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

