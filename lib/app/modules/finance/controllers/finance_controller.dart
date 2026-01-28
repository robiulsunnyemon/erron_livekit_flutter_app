import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/beneficiary_model.dart';
import '../../../data/services/finance_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/utils/snackbar_helper.dart';

class FinanceController extends GetxController {
  final FinanceService _financeService = FinanceService.to;
  final AuthService _auth = AuthService.to;

  var isLoading = false.obs;
  var beneficiaries = <BeneficiaryModel>[].obs;
  var selectedBeneficiary = Rxn<BeneficiaryModel>();
  
  // Link Account Fields
  final accountHolderController = TextEditingController();
  final routingNumberController = TextEditingController();
  final accountNumberController = TextEditingController();
  var selectedMethod = "bank_transfer".obs;

  // Withdrawal Fields
  final withdrawAmountController = TextEditingController();
  var amount = 0.0.obs;
  var tokenRateUsd = 0.05.obs; // Default, will fetch from backend stats
  var platformFeePercent = 10.0.obs; // Default 10%

  @override
  void onInit() {
    super.onInit();
    fetchBeneficiaries();
    // try to fetch real config
    fetchWalletStats();
  }

  Future<void> fetchWalletStats() async {
     try {
      final stats = await _auth.getWalletStats();
      if (stats != null) {
        tokenRateUsd.value = (stats['token_rate_usd'] ?? 0.05).toDouble();
      }
    } catch (_) {}
  }

  void updateAmount(String value) {
    amount.value = double.tryParse(value) ?? 0.0;
  }

  Future<void> fetchBeneficiaries() async {
    isLoading.value = true;
    try {
      beneficiaries.value = await _financeService.getBeneficiaries();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBeneficiary() async {
    if (accountHolderController.text.isEmpty || accountNumberController.text.isEmpty) {
      SnackbarHelper.showError("Error", "Please fill all required fields");
      return;
    }

    isLoading.value = true;
    try {
      final details = {
        'account_holder': accountHolderController.text,
        'routing_number': routingNumberController.text,
        'account_number': accountNumberController.text,
      };
      
      final result = await _financeService.addBeneficiary(selectedMethod.value, details);
      if (result != null) {
        await fetchBeneficiaries();
        Get.back(); // Go back to selection screen
        SnackbarHelper.showSuccess("Success", "Account linked successfully");
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectBeneficiary(BeneficiaryModel beneficiary) {
    selectedBeneficiary.value = beneficiary;
    Get.toNamed(Routes.WITHDRAW_AMOUNT);
  }

  Future<void> submitWithdrawal() async {
    final amount = double.tryParse(withdrawAmountController.text) ?? 0;
    if (amount <= 0) {
      SnackbarHelper.showError("Error", "Please enter a valid amount");
      return;
    }

    if (selectedBeneficiary.value == null) {
      SnackbarHelper.showError("Error", "Please select a payment method");
      return;
    }

    isLoading.value = true;
    try {
      final result = await _financeService.requestPayout(amount, selectedBeneficiary.value!.id);
      if (result != null) {
        Get.offNamed(Routes.PAYOUT_SUCCESS);
        // Refresh profile stats
        try {
           Get.find<ProfileController>().fetchProfile();
           Get.find<ProfileController>().fetchWalletStats();
        } catch (_) {}
      }
    } finally {
      isLoading.value = false;
    }
  }
}
