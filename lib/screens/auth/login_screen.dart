import 'package:flutter/material.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onGetOtp() {
    if (_phoneController.text.trim().length == 10) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            phoneNumber: "+91 ${_phoneController.text.trim()}",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit mobile number."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo & Branding (Center)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text("🥦", style: TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Veggie Mart Vendor",
                    style: AppTextStyles.heading1.copyWith(fontSize: 24, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage your grocery store orders & stock",
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),

                  // Mobile Number Input Field
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mobile Number", style: AppTextStyles.heading3),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: AppTextStyles.bodyLarge,
                          decoration: const InputDecoration(
                            hintText: "Enter 10 digit number",
                            prefixText: "+91 ",
                            counterText: "",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // "Get OTP" Button (Bada button)
                  CustomButton(
                    label: "Get OTP",
                    height: 48,
                    onPressed: _onGetOtp,
                    icon: Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
