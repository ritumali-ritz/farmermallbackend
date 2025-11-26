class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final int? productId;
  final String? senderName;
  final String? receiverName;
  final String? productName;
  final String? productImage;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.productId,
    this.senderName,
    this.receiverName,
    this.productName,
    this.productImage,
    required this.createdAt,
  });

  factory Message.fromMap(Map m) {
    return Message(
      id: m['id'] ?? 0,
      senderId: m['sender_id'] ?? 0,
      receiverId: m['receiver_id'] ?? 0,
      message: m['message'] ?? '',
      productId: m['product_id'],
      senderName: m['sender_name']?.toString(),
      receiverName: m['receiver_name']?.toString(),
      productName: m['product_name']?.toString(),
      productImage: m['product_image']?.toString(),
      createdAt: m['created_at'] != null
          ? DateTime.parse(m['created_at'].toString())
          : DateTime.now(),
    );
  }
}

