class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? imageUrl;
  final String? mobileNumber;
  final String? address;
  final String role; // user, seller, admin, superadmin
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.imageUrl,
    this.mobileNumber,
    this.address,
    this.role = 'user',
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'imageUrl': imageUrl,
      'mobileNumber': mobileNumber,
      'address': address,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get displayName {
    return fullName ?? email;
  }

  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  bool get isSeller => role == 'seller' || role == 'admin' || role == 'superadmin';
  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isSuperAdmin => role == 'superadmin';
}
