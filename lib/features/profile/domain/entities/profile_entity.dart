class AddressEntity {
  final String id;
  final String label;
  final String address;
  final String city;
  final double lat;
  final double lng;

  AddressEntity({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
  });
}

class ProfileUserEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isActive;
  final bool isVerified;
  final List<AddressEntity> addresses;
  final String createdAt;

  ProfileUserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.addresses,
    required this.createdAt,
  });
}
