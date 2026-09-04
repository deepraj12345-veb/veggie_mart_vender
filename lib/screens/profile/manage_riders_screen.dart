import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../models/rider_model.dart';
import '../../providers/riders_provider.dart';
import '../../widgets/custom_button.dart';

class ManageRidersScreen extends ConsumerStatefulWidget {
  const ManageRidersScreen({super.key});

  @override
  ConsumerState<ManageRidersScreen> createState() => _ManageRidersScreenState();
}

class _ManageRidersScreenState extends ConsumerState<ManageRidersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ridersProvider.notifier).refresh());
  }

  void _showAddRiderModal() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final vehicleNoController = TextEditingController();
    final passwordController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Add New Delivery Boy", style: AppTextStyles.heading1),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Mobile Number"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: vehicleNoController,
                    decoration: const InputDecoration(labelText: "Vehicle Number"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Temporary Password"),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: isSaving ? "Saving..." : "Add Rider",
                    onPressed: isSaving ? null : () async {
                      if (nameController.text.trim().isNotEmpty && emailController.text.trim().isNotEmpty && phoneController.text.trim().isNotEmpty) {
                        setModalState(() => isSaving = true);
                        final newRider = RiderModel(
                          id: "", // Will be assigned by API
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          mobileNumber: phoneController.text.trim(),
                          vehicleNumber: vehicleNoController.text.trim(),
                        );
                        try {
                          await ref.read(ridersProvider.notifier).addRider(newRider, passwordController.text.trim());
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Rider added successfully!"),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setModalState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to add rider: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: isSaving ? Icons.hourglass_empty : Icons.check,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ridersAsync = ref.watch(ridersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Delivery Boys", style: AppTextStyles.heading1),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ridersAsync.when(
        data: (riders) {
          if (riders.isEmpty) {
            return Center(
              child: Text("No delivery boys found.", style: AppTextStyles.bodyMedium),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: riders.length,
            itemBuilder: (context, index) {
              final rider = riders[index];
              final isOnline = rider.isActive == "1";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isOnline ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.motorcycle,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  title: Text(rider.name, style: AppTextStyles.bodyLarge),
                  subtitle: Text("${rider.mobileNumber}\n${rider.vehicleNumber}", style: AppTextStyles.bodySmall),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOnline ? "Online" : "Offline",
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Rider?"),
                              content: const Text("Are you sure you want to remove this delivery boy?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            ref.read(ridersProvider.notifier).deleteRider(rider.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRiderModal,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Rider"),
      ),
    );
  }
}
