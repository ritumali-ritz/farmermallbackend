import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../models/banner.dart' as app_banner;
import '../services/storage_service.dart';
import '../theme.dart';
import 'farmer_dashboard.dart';
import 'chat_list_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'daily_services_screen.dart';
import 'profile_screen.dart';
import 'buyer_orders_screen.dart';
import 'farmer_orders_screen.dart';
import '../services/order_notification_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  List<app_banner.Banner> banners = [];
  List<Map<String, dynamic>> recentOrders = [];
  bool loading = true;
  bool loadingOrders = false;
  int _currentBannerIndex = 0;
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    fetchProducts(showLoader: true);
    fetchBanners();
    _loadUserAndOrders();
  }

  Future<void> _loadUserAndOrders() async {
    final user = await StorageService.getMap('current_user');
    setState(() {
      currentUser = user;
    });
    if (user != null) {
      fetchRecentOrders();
      // Initialize order notifications for farmers
      if (user['role'] == 'farmer') {
        OrderNotificationService.initialize(context);
      }
    }
  }

  Future<void> fetchRecentOrders() async {
    if (currentUser == null) return;
    setState(() => loadingOrders = true);

    final userId = currentUser!['id'];
    final role = currentUser!['role'];
    final endpoint =
        role == 'farmer' ? '/order/farmer/$userId' : '/order/buyer/$userId';

    final res = await ApiService.get(endpoint);
    if (!mounted) return;

    if (res['statusCode'] == 200 && res['body'] is List) {
      final allOrders = (res['body'] as List).cast<Map<String, dynamic>>();
      setState(() {
        recentOrders = allOrders.take(3).toList(); // Show only 3 recent orders
        loadingOrders = false;
      });
    } else {
      setState(() => loadingOrders = false);
    }
  }

  Future<void> fetchBanners() async {
    try {
      final res = await ApiService.get('/banner/active');
      if (!mounted) return;

      if (res['statusCode'] == 200 && res['body'] is List) {
        final bannerList = (res['body'] as List)
            .map((b) {
              try {
                return app_banner.Banner.fromMap(b as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing banner: $e');
                return null;
              }
            })
            .whereType<app_banner.Banner>()
            .toList();

        setState(() {
          banners = bannerList;
        });
      } else {
        // Use fallback banners from banner folder
        _setFallbackBanners();
      }
    } catch (e) {
      print('Error fetching banners: $e');
      // Use fallback banners from banner folder
      _setFallbackBanners();
    }
  }

  void _setFallbackBanners() {
    // Fallback banners using banner folder images
    final baseUrl = ApiService.baseUrl;
    setState(() {
      banners = [
        app_banner.Banner(
          id: 1,
          title: 'Organic Products - Best Quality',
          imageUrl: '$baseUrl/banner-files/Organic Products - Best Quality.jpg',
          linkUrl: '/products',
          displayOrder: 1,
          status: 'active',
        ),
        app_banner.Banner(
          id: 2,
          title: 'Fresh Vegetables - Daily Delivery',
          imageUrl:
              '$baseUrl/banner-files/Fresh Vegetables - Daily Delivery.jpg',
          linkUrl: '/products?category=vegetables',
          displayOrder: 2,
          status: 'active',
        ),
        app_banner.Banner(
          id: 3,
          title: 'New Arrivals - Check Now',
          imageUrl: '$baseUrl/banner-files/New Arrivals - Check Now.jpg',
          linkUrl: '/products?category=new',
          displayOrder: 3,
          status: 'active',
        ),
      ];
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> fetchProducts({bool showLoader = false}) async {
    if (showLoader) {
      setState(() => loading = true);
    }

    final res = await ApiService.get('/farmer/allProducts');
    if (!mounted) return;

    final code = res['statusCode'];
    final body = res['body'];
    if ((code == 200 || code == 201) && body is List) {
      final parsedProducts =
          body.whereType<Map<String, dynamic>>().map(Product.fromMap).toList();

      // Remove initial demo products named like 'Fresh Tomatoes...' from home
      final filtered = parsedProducts
          .where((p) => !p.name.toLowerCase().startsWith('fresh tomatoes'))
          .toList();

      setState(() {
        products = filtered;
        loading = false;
      });
    } else {
      setState(() => loading = false);
      _showMessage('Failed loading products');
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FDF4), // Very light green
              Color(0xFFECFDF5), // Light green
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Farmer Mall',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.local_grocery_store),
                onPressed: () async {
                  final user = await StorageService.getMap('current_user');
                  if (user == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () async {
                  final user = await StorageService.getMap('current_user');
                  if (user == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatListScreen()),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.store),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerDashboard()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyServicesScreen()),
            ),
            icon: const Icon(Icons.delivery_dining),
            label: const Text('Daily Services'),
            backgroundColor: kPrimaryGreen,
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    await fetchProducts();
                    await fetchBanners();
                    await _loadUserAndOrders();
                  },
                  child: CustomScrollView(
                    slivers: [
                      // Banner Carousel
                      if (banners.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                CarouselSlider.builder(
                                  itemCount: banners.length,
                                  itemBuilder: (context, index, realIndex) {
                                    final banner = banners[index];
                                    // Resolve image URL - handle both relative and absolute paths
                                    String imageUrl = banner.imageUrl;

                                    // If already absolute URL, use as is
                                    if (imageUrl.startsWith('http://') ||
                                        imageUrl.startsWith('https://')) {
                                      // Already absolute, use as is
                                    } else {
                                      // Handle relative paths
                                      if (imageUrl
                                          .startsWith('/banner-files/')) {
                                        imageUrl =
                                            '${ApiService.baseUrl}$imageUrl';
                                      } else if (imageUrl
                                          .startsWith('banner-files/')) {
                                        imageUrl =
                                            '${ApiService.baseUrl}/$imageUrl';
                                      } else if (!imageUrl.contains('://')) {
                                        // If no protocol, assume it's a relative path
                                        if (!imageUrl.startsWith('/')) {
                                          imageUrl = '/$imageUrl';
                                        }
                                        imageUrl =
                                            '${ApiService.baseUrl}$imageUrl';
                                      } else {
                                        imageUrl = ApiService.resolveMediaUrl(
                                                banner.imageUrl) ??
                                            banner.imageUrl;
                                      }
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        // Handle banner tap - could navigate to products or specific page
                                        if (banner.linkUrl != null) {
                                          // Navigate based on link
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholder: (context, url) =>
                                                Container(
                                              height: 180,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                            errorWidget: (context, url, error) {
                                              print(
                                                  'Banner image error: $error for URL: $url');
                                              // Try to load a default banner or show placeholder
                                              return Container(
                                                height: 180,
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF10B981),
                                                      Color(0xFF14B8A6)
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.local_florist,
                                                        color: Colors.white,
                                                        size: 40),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      banner.title ??
                                                          'Farmer Mall',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  options: CarouselOptions(
                                    height: 180,
                                    viewportFraction: 0.95,
                                    autoPlay: true,
                                    autoPlayInterval:
                                        const Duration(seconds: 3),
                                    autoPlayAnimationDuration:
                                        const Duration(milliseconds: 800),
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    enlargeCenterPage: true,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _currentBannerIndex = index;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      banners.asMap().entries.map((entry) {
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentBannerIndex == entry.key
                                            ? kPrimaryGreen
                                            : Colors.grey[300],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Recent Orders Section (if logged in)
                      if (currentUser != null && recentOrders.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Recent Orders',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                currentUser!['role'] == 'farmer'
                                                    ? const FarmerOrdersScreen()
                                                    : const BuyerOrdersScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text('View All'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: recentOrders.length,
                                    itemBuilder: (context, index) {
                                      final order = recentOrders[index];
                                      try {
                                        return Container(
                                          width: 200,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          child: Card(
                                            elevation: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    order['product_name'] ??
                                                        'Product',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Qty: ${_parseInt(order['quantity'])}',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '₹${_parseDouble(order['total_amount']).toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: kAccentOrange,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(
                                                              _parseString(order[
                                                                  'order_status']))
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      _parseString(order[
                                                              'order_status'])
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: _getStatusColor(
                                                            _parseString(order[
                                                                'order_status'])),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        print('Error rendering order card: $e');
                                        return Container(
                                          width: 200,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          child: const Card(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                'Error loading order',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      // Products Grid
                      products.isEmpty
                          ? const SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shopping_bag_outlined,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('No products available',
                                        style: TextStyle(color: Colors.grey)),
                                    SizedBox(height: 8),
                                    Text('Pull to refresh',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.all(12),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final p = products[index];
                                    return _ProductCard(product: p);
                                  },
                                  childCount: products.length,
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
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  String get _imageUrl {
    return ApiService.resolveMediaUrl(product.imageUrl) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: const BoxDecoration(
            gradient: kCardGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _imageUrl.isNotEmpty
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
                                color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image,
                              size: 50, color: Colors.grey[400]),
                        ),
                ),
              ),
              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: kAccentOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.inventory_2,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${product.quantity} available',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
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
      ),
    );
  }
}
