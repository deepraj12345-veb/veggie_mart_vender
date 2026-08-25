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
      backgroundColor: Colors.transparent,
      builder: (context) => AssignRiderModal(order: order, onAssign: onAssign),
    );
  }

  @override
  State<AssignRiderModal> createState() => _AssignRiderModalState();
}

class _AssignRiderModalState extends State<AssignRiderModal> {
  List<RiderModel> _riders = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchRiders();
  }

  Future<void> _fetchRiders() async {
    try {
      final riders = await ApiService.fetchRiders();
      if (mounted) {
        setState(() {
          _riders = riders.where((r) => r.isActive == "1").toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load delivery boys';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Assign Delivery Boy", style: AppTextStyles.heading2),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Order ID: ${widget.order.id}",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                ? Center(
                    child: Text(
                      _error,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  )
                : _riders.isEmpty
                ? const Center(
                    child: Text(
                      "No active delivery boys available.",
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                    ),
                    itemCount: _riders.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final rider = _riders[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(
                            Icons.delivery_dining,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(rider.name, style: AppTextStyles.heading3),
                        subtitle: Text(
                          rider.mobileNumber,
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onAssign(rider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Assign",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
