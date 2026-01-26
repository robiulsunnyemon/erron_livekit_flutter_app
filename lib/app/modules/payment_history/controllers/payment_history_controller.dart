import 'package:get/get.dart';
import '../../../data/models/payout_model.dart';
import '../../../data/services/auth_service.dart';

class PaymentHistoryController extends GetxController {
  final AuthService _authService = AuthService.to;
  
  final payoutHistory = <PayoutRequestModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPayoutHistory();
  }

  Future<void> fetchPayoutHistory() async {
    isLoading.value = true;
    try {
      final history = await _authService.getPayoutHistory();
      payoutHistory.assignAll(history);
    } finally {
      isLoading.value = false;
    }
  }
}
