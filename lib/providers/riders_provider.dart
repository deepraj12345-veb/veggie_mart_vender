import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rider_model.dart';
import '../services/api_service.dart';

class RidersNotifier extends AsyncNotifier<List<RiderModel>> {
  @override
  Future<List<RiderModel>> build() async {
    return _fetchRiders();
  }

  Future<List<RiderModel>> _fetchRiders() async {
    try {
      return await ApiService.fetchRiders();
    } catch (e) {
      print('Error fetching riders: $e');
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRiders());
  }

  Future<void> addRider(RiderModel newRider, String password) async {
    try {
      final createdRider = await ApiService.addRider(newRider, password);
      if (state.value != null) {
        state = AsyncValue.data([...state.value!, createdRider]);
      }
    } catch (e) {
      print('Error adding rider: $e');
      rethrow;
    }
  }

  Future<void> updateRiderStatus(String riderId, String isActive) async {
    try {
      await ApiService.updateRiderStatus(riderId, isActive);
      if (state.value != null) {
        state = AsyncValue.data([
          for (final rider in state.value!)
            if (rider.id == riderId)
              rider.copyWith(isActive: isActive)
            else
              rider
        ]);
      }
    } catch (e) {
      print('Error updating rider status: $e');
    }
  }

  Future<void> deleteRider(String riderId) async {
    try {
      await ApiService.deleteRider(riderId);
      if (state.value != null) {
        state = AsyncValue.data(
          state.value!.where((r) => r.id != riderId).toList(),
        );
      }
    } catch (e) {
      print('Error deleting rider: $e');
    }
  }
}

final ridersProvider = AsyncNotifierProvider<RidersNotifier, List<RiderModel>>(RidersNotifier.new);
