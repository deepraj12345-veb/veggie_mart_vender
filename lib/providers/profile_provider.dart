import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class VendorProfileState {
  final String vendorId;
  final String vendorName;
  final String email;
  final String phoneNumber;
  final String storeName;
  final String storeAddress;
  final String city;
  final String stateName;
  final double walletBalance;
  final bool isVerified;
  final String language; // "English" or "Hindi"
  final bool isLoading;

  const VendorProfileState({
    required this.vendorId,
    required this.vendorName,
    required this.email,
    required this.phoneNumber,
    required this.storeName,
    required this.storeAddress,
    required this.city,
    required this.stateName,
    required this.walletBalance,
    required this.isVerified,
    required this.language,
    this.isLoading = false,
  });

  VendorProfileState copyWith({
    String? vendorId,
    String? vendorName,
    String? email,
    String? phoneNumber,
    String? storeName,
    String? storeAddress,
    String? city,
    String? stateName,
    double? walletBalance,
    bool? isVerified,
    String? language,
    bool? isLoading,
  }) {
    return VendorProfileState(
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      city: city ?? this.city,
      stateName: stateName ?? this.stateName,
      walletBalance: walletBalance ?? this.walletBalance,
      isVerified: isVerified ?? this.isVerified,
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileNotifier extends Notifier<VendorProfileState> {
  @override
  VendorProfileState build() {
    _loadAndSync();
    return VendorProfileState(
      vendorId: ApiService.currentVendorId ?? "",
      vendorName: ApiService.vendorName ?? "",
      email: ApiService.currentVendorEmail ?? "",
      phoneNumber: ApiService.vendorPhone ?? "",
      storeName: ApiService.storeName ?? "",
      storeAddress: ApiService.storeAddress ?? "",
      city: ApiService.city,
      stateName: ApiService.stateName,
      walletBalance: ApiService.walletBalance,
      isVerified: ApiService.isVerified,
      language: "English",
    );
  }

  Future<void> fetchProfileFromApi() async {
    state = state.copyWith(isLoading: true);
    final vendorData = await ApiService.fetchVendorProfile();
    if (vendorData.isNotEmpty) {
      state = state.copyWith(
        vendorId: ApiService.currentVendorId ?? state.vendorId,
        vendorName: ApiService.vendorName ?? state.vendorName,
        email: ApiService.currentVendorEmail ?? state.email,
        phoneNumber: ApiService.vendorPhone ?? state.phoneNumber,
        storeName: ApiService.storeName ?? state.storeName,
        storeAddress: ApiService.storeAddress ?? state.storeAddress,
        city: ApiService.city,
        stateName: ApiService.stateName,
        walletBalance: ApiService.walletBalance,
        isVerified: ApiService.isVerified,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadAndSync() async {
    try {
      await ApiService.loadFromPrefs();
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('currentVendorId') ?? ApiService.currentVendorId;
      final name = prefs.getString('vendorName') ?? ApiService.vendorName;
      final email = prefs.getString('currentVendorEmail') ?? ApiService.currentVendorEmail;
      final phone = prefs.getString('vendorPhone') ?? ApiService.vendorPhone;
      final store = prefs.getString('storeName') ?? ApiService.storeName;
      final address = prefs.getString('storeAddress') ?? ApiService.storeAddress;
      final c = prefs.getString('vendorCity') ?? ApiService.city;
      final s = prefs.getString('vendorState') ?? ApiService.stateName;
      final w = prefs.getDouble('vendorWallet') ?? ApiService.walletBalance;
      final v = prefs.getBool('vendorIsVerified') ?? ApiService.isVerified;

      state = state.copyWith(
        vendorId: id ?? state.vendorId,
        vendorName: name ?? state.vendorName,
        email: email ?? state.email,
        phoneNumber: phone ?? state.phoneNumber,
        storeName: store ?? state.storeName,
        storeAddress: address ?? state.storeAddress,
        city: c,
        stateName: s,
        walletBalance: w,
        isVerified: v,
      );

      await fetchProfileFromApi();
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
    String? email,
    String? phoneNumber,
    String? storeName,
    String? storeAddress,
    String? city,
    String? stateName,
  }) async {
    state = state.copyWith(
      vendorName: vendorName,
      email: email,
      phoneNumber: phoneNumber,
      storeName: storeName,
      storeAddress: storeAddress,
      city: city,
      stateName: stateName,
    );

    if (vendorName != null) ApiService.vendorName = vendorName;
    if (email != null) ApiService.currentVendorEmail = email;
    if (phoneNumber != null) ApiService.vendorPhone = phoneNumber;
    if (storeName != null) ApiService.storeName = storeName;
    if (storeAddress != null) ApiService.storeAddress = storeAddress;
    if (city != null) ApiService.city = city;
    if (stateName != null) ApiService.stateName = stateName;

    await ApiService.saveToPrefs();
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, VendorProfileState>(ProfileNotifier.new);
