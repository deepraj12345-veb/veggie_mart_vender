import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreStatusNotifier extends Notifier<bool> {
  @override
  bool build() => true; // Default: Store is Open

  void toggleStatus() {
    state = !state;
  }

  void setStatus(bool isOpen) {
    state = isOpen;
  }
}

final storeStatusProvider = NotifierProvider<StoreStatusNotifier, bool>(StoreStatusNotifier.new);
