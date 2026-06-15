class CustomerProfile {
  final String phone;
  final String addressLine;
  final String city;
  final String? birthDate;

  const CustomerProfile({
    required this.phone,
    required this.addressLine,
    required this.city,
    this.birthDate,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      phone: json['phone'] as String,
      addressLine: json['address_line'] as String,
      city: json['city'] as String,
      birthDate: json['birth_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'address_line': addressLine,
      'city': city,
      'birth_date': birthDate,
    };
  }
}

class User {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final String createdAt;
  final CustomerProfile? profile;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.profile,
  });

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      profile: json['profile'] != null
          ? CustomerProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt,
      'profile': profile?.toJson(),
    };
  }
}
