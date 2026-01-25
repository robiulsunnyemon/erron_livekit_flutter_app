import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Enter Email Address",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
             const SizedBox(height: 48),

            // Email Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Email", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "you@example.com",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color(0xFF0F0F1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 16),
             Align(
               alignment: Alignment.centerRight,
               child: GestureDetector(
                 onTap: () => Get.offNamed(Routes.LOGIN),
                 child: const Text("Back to sign in", style: TextStyle(color: Colors.white70, fontSize: 12)),
               ),
             ),

            const SizedBox(height: 48),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.forgotPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C4DDC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 8,
                  shadowColor: const Color(0xFF4C4DDC).withOpacity(0.5),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
