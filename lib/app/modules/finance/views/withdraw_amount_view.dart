import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/finance_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class WithdrawAmountView extends GetView<FinanceController> {
  const WithdrawAmountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Withdraw amount',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Withdraw amount", style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            Obx(() => Text(
              "\$${(controller.amount.value * controller.tokenRateUsd.value).toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
            )),
            const SizedBox(height: 8),
            Obx(() => Text(
              "Available: \$${profileCtrl.fiatValue.value.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            )),
            const SizedBox(height: 48),
            _buildAmountInput(),
            const SizedBox(height: 40),
            _buildBreakdown(),
            const SizedBox(height: 60),
            Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : _buildWithdrawButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextField(
      controller: controller.withdrawAmountController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 24),
      onChanged: controller.updateAmount,
      decoration: InputDecoration(
        hintText: "Enter amount",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 24),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2E3FE7))),
        suffixIcon: TextButton(
          onPressed: () {
            final profileCtrl = Get.find<ProfileController>();
            final maxAmount = profileCtrl.coinBalance.value.toInt().toString();
            controller.withdrawAmountController.text = maxAmount;
            controller.updateAmount(maxAmount);
          },
          child: const Text("Max", style: TextStyle(color: Color(0xFF2E3FE7))),
        ),
      ),
    );
  }

  Widget _buildBreakdown() {
    return Column(
      children: [
        Obx(() => _buildBreakdownRow(
          "Withdrawal Amount", 
          Text("\$${(controller.amount.value * controller.tokenRateUsd.value).toStringAsFixed(2)}", style: const TextStyle(color: Colors.white)),
        )),
        const SizedBox(height: 12),
        Obx(() => _buildBreakdownRow(
          "Platform Fee (10%)", 
          Text("-\$${(controller.amount.value * controller.tokenRateUsd.value * 0.1).toStringAsFixed(2)}", style: const TextStyle(color: Colors.redAccent)),
        )),
        const SizedBox(height: 12),
        const Divider(color: Colors.white12),
        const SizedBox(height: 12),
        Obx(() => _buildBreakdownRow(
          "Your receive", 
          Text(
            "\$${(controller.amount.value * controller.tokenRateUsd.value * 0.9).toStringAsFixed(2)}", 
            style: const TextStyle(color: Color(0xFF2E3FE7), fontWeight: FontWeight.bold, fontSize: 18),
          ), 
          isMain: true,
        )),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, Widget value, {bool isMain = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label, 
            style: TextStyle(color: isMain ? Colors.white : Colors.white54, fontSize: isMain ? 16 : 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        value,
      ],
    );
  }

  Widget _buildWithdrawButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => controller.submitWithdrawal(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E3FE7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          "Confirm Withdrawal",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
