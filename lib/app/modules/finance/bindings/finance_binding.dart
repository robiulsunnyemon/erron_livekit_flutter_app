import 'package:get/get.dart';
import '../controllers/finance_controller.dart';
import '../../../data/services/finance_service.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinanceService>(() => FinanceService());
    Get.lazyPut<FinanceController>(() => FinanceController());
  }
}
