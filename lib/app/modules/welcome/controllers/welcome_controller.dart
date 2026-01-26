import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/auth_service.dart';

class WelcomeController extends GetxController {
  final _storage = GetStorage();
  final String _storageKey = 'has_seen_welcome';

  @override
  void onReady() {
    super.onReady();
    _checkWelcomeStatus();
  }

  void _checkWelcomeStatus() {
    // If the flag is set, redirect immediately
    if (_storage.read(_storageKey) == true) {
      _navigateToMain();
    }
  }

  void onGetStarted() {
    // Set the flag and move to the main app
    _storage.write(_storageKey, true);
    _navigateToMain();
  }

  void _navigateToMain() {
    // If logged in, go to Dashboard, otherwise Login
    if (AuthService.to.isLoggedIn) {
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
