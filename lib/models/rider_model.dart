class RiderModel {
  final String id;
  final String name;
  final String mobileNumber;
  final String vehicleType;
  final String vehicleNumber;
  final String isActive; // "1" for online, "0" for offline
  final double walletBalance;

  RiderModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    this.vehicleType = "Bike",
    this.vehicleNumber = "",
    this.isActive = "0",
    this.walletBalance = 0.0,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      vehicleType: json['vehicle_type'] ?? 'Bike',
      vehicleNumber: json['vehicle_number'] ?? '',
      isActive: json['is_active']?.toString() ?? '0',
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'mobile_number': mobileNumber,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'is_active': isActive,
      'wallet_balance': walletBalance,
    };
  }

  RiderModel copyWith({
    String? id,
    String? name,
    String? mobileNumber,
    String? vehicleType,
    String? vehicleNumber,
    String? isActive,
    double? walletBalance,
  }) {
    return RiderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      isActive: isActive ?? this.isActive,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}
