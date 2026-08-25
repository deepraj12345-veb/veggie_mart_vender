class RiderModel {
  final String id;
  final String name;
  final String email;
  final String mobileNumber;
  final String vehicleType;
  final String vehicleNumber;
  final String? vendorId;
  final String? licenceImage;
  final String? profileImage;
  final String isActive; // "1" for active, "0" for inactive
  final String isVerified;
  final double walletBalance;

  RiderModel({
    required this.id,
    required this.name,
    this.email = "",
    required this.mobileNumber,
    this.vehicleType = "Bike",
    this.vehicleNumber = "",
    this.vendorId,
    this.licenceImage,
    this.profileImage,
    this.isActive = "1",
    this.isVerified = "1",
    this.walletBalance = 0.0,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      vehicleType: json['vehicle_type'] ?? 'Bike',
      vehicleNumber: json['vehicle_number'] ?? '',
      vendorId: json['vendor_id'] is Map
          ? json['vendor_id']['_id']?.toString()
          : json['vendor_id']?.toString(),
      licenceImage: json['licence_image'],
      profileImage: json['profile_image'],
      isActive: json['is_active']?.toString() ?? '1',
      isVerified: json['is_verified']?.toString() ?? '1',
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'mobile_number': mobileNumber,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'is_active': isActive,
      'is_verified': isVerified,
      'wallet_balance': walletBalance,
    };

    if (id.isNotEmpty) data['_id'] = id;
    if (vendorId != null) data['vendor_id'] = vendorId;
    if (licenceImage != null) data['licence_image'] = licenceImage;
    if (profileImage != null) data['profile_image'] = profileImage;

    return data;
  }

  RiderModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobileNumber,
    String? vehicleType,
    String? vehicleNumber,
    String? vendorId,
    String? licenceImage,
    String? profileImage,
    String? isActive,
    String? isVerified,
    double? walletBalance,
  }) {
    return RiderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vendorId: vendorId ?? this.vendorId,
      licenceImage: licenceImage ?? this.licenceImage,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}
