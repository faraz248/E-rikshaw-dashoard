class AdminModel {
  final String uid;
  final String name;
  final String email;
  final String shopId;
  final String shopName;
  final String? photoUrl;
  final String role;

  AdminModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.shopId,
    required this.shopName,
    this.photoUrl,
    this.role = 'admin',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'shopId': shopId,
      'shopName': shopName,
      'photoUrl': photoUrl,
      'role': role,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? '',
      photoUrl: map['photoUrl'],
      role: map['role'] ?? 'admin',
    );
  }
}
