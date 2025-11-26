class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? token;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] is num ? (map['id'] as num).toInt() : int.tryParse('${map['id']}') ?? 0,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'buyer',
      token: map['token']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (token != null) 'token': token,
    };
  }
}
