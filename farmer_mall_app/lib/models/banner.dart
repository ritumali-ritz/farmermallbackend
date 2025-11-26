class Banner {
  final int id;
  final String? title;
  final String imageUrl;
  final String? linkUrl;
  final int displayOrder;
  final String status;

  Banner({
    required this.id,
    this.title,
    required this.imageUrl,
    this.linkUrl,
    required this.displayOrder,
    required this.status,
  });

  factory Banner.fromMap(Map<String, dynamic> map) {
    return Banner(
      id: map['id'] as int,
      title: map['title'] as String?,
      imageUrl: map['image_url'] as String,
      linkUrl: map['link_url'] as String?,
      displayOrder: map['display_order'] as int? ?? 0,
      status: map['status'] as String? ?? 'active',
    );
  }
}

