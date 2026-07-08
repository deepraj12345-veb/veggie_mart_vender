import 'dart:async';
import 'package:flutter/material.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../main_nav_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController(text: "1234");
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (_otpController.text.trim().length >= 4) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter valid 4-digit OTP."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Verify OTP"),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter Verification Code",
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 6),
              Text(
                "We have sent a 4-digit verification code to ${widget.phoneNumber}",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              // OTP Input Field
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
                    Text("4-Digit OTP Code", style: AppTextStyles.heading3),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading1.copyWith(letterSpacing: 8, fontSize: 22),
                      decoration: const InputDecoration(
                        hintText: "• • • •",
                        counterText: "",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Countdown Timer & Resend Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _secondsRemaining > 0
                        ? "00:${_secondsRemaining.toString().padLeft(2, '0')}s remaining"
                        : "Code expired",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _secondsRemaining > 0 ? AppColors.warning : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: _secondsRemaining == 0 ? _startTimer : null,
                    child: Text(
                      "Resend OTP",
                      style: AppTextStyles.buttonText.copyWith(
                        color: _secondsRemaining == 0 ? AppColors.primary : AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // "Verify & Login" Button
              CustomButton(
                label: "Verify & Login",
                height: 48,
                onPressed: _onVerify,
                icon: Icons.check_circle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
