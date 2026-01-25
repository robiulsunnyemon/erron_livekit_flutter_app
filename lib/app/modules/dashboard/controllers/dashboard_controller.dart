import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    if (index == 2) {
      // Start Live tab index
      Get.toNamed(Routes.START_LIVE);
    } else {
      currentIndex.value = index;
    }
  }
}
