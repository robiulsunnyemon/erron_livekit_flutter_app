import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/snackbar_helper.dart';

class KYCController extends GetxController {
  final AuthService _authService = AuthService.to;
  final ImagePicker _picker = ImagePicker();

  var frontImagePath = ''.obs;
  var backImagePath = ''.obs;
  var isLoading = false.obs;
  var kycStatus = 'none'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKYCStatus();
  }

  Future<void> fetchKYCStatus() async {
    final statusData = await _authService.getKYCStatus();
    if (statusData != null) {
      kycStatus.value = statusData['status'] ?? 'none';
    }
  }

  Future<void> pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (isFront) {
        frontImagePath.value = image.path;
      } else {
        backImagePath.value = image.path;
      }
    }
  }

  Future<void> submitKYC() async {
    if (frontImagePath.isEmpty || backImagePath.isEmpty) {
      SnackbarHelper.showError("Error", "Please upload both front and back images of your ID");
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authService.submitKYC(frontImagePath.value, backImagePath.value);
      if (result != null) {
        kycStatus.value = result['status'];
        SnackbarHelper.showSuccess("Success", "KYC submitted successfully. Please wait for verification.");
        // Redirect to Withdrawal screen as requested
        Get.offNamed(Routes.WITHDRAW_TO); 
      }
    } finally {
      isLoading.value = false;
    }
  }
}
