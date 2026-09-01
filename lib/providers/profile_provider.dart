import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

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
  VendorProfileState build() {
    _loadFromPrefs();
    return VendorProfileState(
      vendorName: ApiService.vendorName ?? "",
      phoneNumber: ApiService.vendorPhone ?? "",
      storeName: ApiService.storeName ?? "",
      storeAddress: ApiService.storeAddress ?? "",
      language: "English",
    );
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('vendorName') ?? ApiService.vendorName;
      final phone = prefs.getString('vendorPhone') ?? ApiService.vendorPhone;
      final store = prefs.getString('storeName') ?? ApiService.storeName;
      final address = prefs.getString('storeAddress') ?? ApiService.storeAddress;

      state = state.copyWith(
        vendorName: name ?? state.vendorName,
        phoneNumber: phone ?? state.phoneNumber,
        storeName: store ?? state.storeName,
        storeAddress: address ?? state.storeAddress,
      );
    } catch (_) {}
  }

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
  }) async {
    state = state.copyWith(
      vendorName: vendorName,
      phoneNumber: phoneNumber,
      storeName: storeName,
      storeAddress: storeAddress,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      if (vendorName != null) prefs.setString('vendorName', vendorName);
      if (phoneNumber != null) prefs.setString('vendorPhone', phoneNumber);
      if (storeName != null) prefs.setString('storeName', storeName);
      if (storeAddress != null) prefs.setString('storeAddress', storeAddress);
    } catch (_) {}
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, VendorProfileState>(ProfileNotifier.new);
