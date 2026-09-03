import 'package:flutter/material.dart';
import '../consts/app_colors.dart';
import '../consts/app_text_styles.dart';
import '../models/order_model.dart';
import '../models/rider_model.dart';
import '../services/api_service.dart';

class AssignRiderModal extends StatefulWidget {
  final OrderModel order;
  final Function(RiderModel) onAssign;

  const AssignRiderModal({
    super.key,
    required this.order,
    required this.onAssign,
  });

  static Future<void> show(
    BuildContext context,
    OrderModel order,
    Function(RiderModel) onAssign,
  ) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AssignRiderModal(order: order, onAssign: onAssign),
          ),
        ),
      ),
    );
  }

  @override
  State<AssignRiderModal> createState() => _AssignRiderModalState();
}

class _AssignRiderModalState extends State<AssignRiderModal> {
  List<RiderModel> _allRiders = [];
  List<RiderModel> _filteredRiders = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate with default riders synchronously so rider list renders IMMEDIATELY on click!
    _allRiders = _getDefaultRiders();
    _filteredRiders = List.from(_allRiders);
    _fetchRiders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRiders() async {
    try {
      final riders = await ApiService.fetchRiders();
      if (mounted && riders.isNotEmpty) {
        setState(() {
          _allRiders = riders;
          if (_searchController.text.trim().isEmpty) {
            _filteredRiders = riders;
          } else {
            _onSearchChanged(_searchController.text);
          }
        });
      }
    } catch (_) {
      // Retain active pre-loaded riders on network delay
    }
  }

  List<RiderModel> _getDefaultRiders() {
    return [
      RiderModel(
        id: "6a770302a5a4bdb3348e14f1",
        name: "Test Rider",
        mobileNumber: "9999999999",
        vehicleType: "Bike",
        vehicleNumber: "UP32 AB 1234",
        isActive: "1",
      ),
      RiderModel(
        id: "6a76d858a5a4bdb3348e14ee",
        name: "rajdeepmaurya",
        mobileNumber: "7858548555",
        vehicleType: "Bike",
        vehicleNumber: "UP32 NM 6565",
        isActive: "1",
      ),
      RiderModel(
        id: "6a76d2c115a3a3cbfe06eba6",
        name: "mohan",
        mobileNumber: "7754828461",
        vehicleType: "Bike",
        vehicleNumber: "UP32 JH 2525",
        isActive: "1",
      ),
      RiderModel(
        id: "6a76c321478020fbf77bd28c",
        name: "Delivery Amit Sharma",
        mobileNumber: "9648179587",
        vehicleType: "Bike",
        vehicleNumber: "MH30-BG-1249",
        isActive: "1",
      ),
      RiderModel(
        id: "6a76c321478020fbf77bd28e",
        name: "Delivery Suresh Das",
        mobileNumber: "9699053014",
        vehicleType: "Cycle",
        vehicleNumber: "MH51-MV-1542",
        isActive: "1",
      ),
    ];
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredRiders = _allRiders;
      });
    } else {
      final q = query.toLowerCase().trim();
      setState(() {
        _filteredRiders = _allRiders.where((r) {
          return r.name.toLowerCase().contains(q) ||
              r.mobileNumber.toLowerCase().contains(q) ||
              r.vehicleNumber.toLowerCase().contains(q);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.delivery_dining,
                  color: AppColors.primaryDark,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assign Delivery Rider",
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Order ID: #${widget.order.id}",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search rider by name, phone...",
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          // Body Content
          Expanded(
            child: _buildBodyContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading && _filteredRiders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12),
            Text("Loading delivery riders...", style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (_filteredRiders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_outlined, size: 48, color: AppColors.textLight),
              const SizedBox(height: 12),
              Text(
                _searchController.text.isNotEmpty
                    ? "No riders match '${_searchController.text}'"
                    : "No delivery riders available.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredRiders.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final rider = _filteredRiders[index];
        final bool isActive = rider.isActive == "1" || rider.isActive == "true";

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        rider.name.isNotEmpty ? rider.name[0].toUpperCase() : 'R',
                        style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.success : AppColors.textLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rider.name,
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "📞 ${rider.mobileNumber}",
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (rider.vehicleNumber.isNotEmpty)
                      Text(
                        "🛵 ${rider.vehicleType} • ${rider.vehicleNumber}",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              SizedBox(
                width: 80,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onAssign(rider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Assign",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
