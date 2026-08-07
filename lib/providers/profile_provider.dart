import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorProfileState {
  final String vendorName;
  final String phoneNumber;
  final String storeName;
  final String storeAddress;
  final String language; // "English" or "Hindi"

  const VendorProfileState({
    required this.vendorName,
    required this.phoneNumber,
    required this.storeName,
    required this.storeAddress,
    required this.language,
  });

  VendorProfileState copyWith({
    String? vendorName,
    String? phoneNumber,
    String? storeName,
    String? storeAddress,
    String? language,
  }) {
    return VendorProfileState(
      vendorName: vendorName ?? this.vendorName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      language: language ?? this.language,
    );
  }
}

class ProfileNotifier extends Notifier<VendorProfileState> {
  @override
  VendorProfileState build() => const VendorProfileState(
        vendorName: "Vendor Name",
        phoneNumber: "",
        storeName: "Store Name",
        storeAddress: "Store Address",
        language: "English",
      );

  void toggleLanguage() {
    state = state.copyWith(
      language: state.language == "English" ? "Hindi" : "English",
    );
  }

  void updateLanguage(String lang) {
    state = state.copyWith(language: lang);
  }

  void updateProfile({
    String? vendorName,
    String? phoneNumber,
    String? storeName,
    String? storeAddress,
  }) {
    state = state.copyWith(
      vendorName: vendorName,
      phoneNumber: phoneNumber,
      storeName: storeName,
      storeAddress: storeAddress,
    );
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, VendorProfileState>(ProfileNotifier.new);
