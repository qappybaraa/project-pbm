// ============================================================
// lib/models/user_model.dart
// ============================================================

enum UserRole { buyer, seller, admin }
enum UserStatus { active, inactive, banned }
enum SellerStatus { pending, verified, rejected }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final UserStatus status;
  final SellerStatus? sellerStatus; // only for seller
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.status = UserStatus.active,
    this.sellerStatus,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? phone,
    UserStatus? status,
    SellerStatus? sellerStatus,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      status: status ?? this.status,
      sellerStatus: sellerStatus ?? this.sellerStatus,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt,
    );
  }
}