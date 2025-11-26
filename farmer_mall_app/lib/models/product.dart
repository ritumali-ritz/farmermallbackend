class Product {
  final int id;
  final int farmerId;
  final String name;
  final double price;
  final int quantity;
  final String? description;
  final String? imageUrl;

  Product({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.price,
    required this.quantity,
    this.description,
    this.imageUrl,
  });

  factory Product.fromMap(Map m) {
    return Product(
      id: m['id'] ?? m['product_id'] ?? 0,
      farmerId: m['farmer_id'] ?? 0,
      name: m['name'] ?? '',
      price: (m['price'] is num)
          ? (m['price'] as num).toDouble()
          : double.tryParse('${m['price']}') ?? 0.0,
      quantity: (m['quantity'] is num)
          ? (m['quantity'] as num).toInt()
          : int.tryParse('${m['quantity']}') ?? 0,
      description: m['description']?.toString(),
      imageUrl: m['image_url']?.toString(),
    );
  }
}
