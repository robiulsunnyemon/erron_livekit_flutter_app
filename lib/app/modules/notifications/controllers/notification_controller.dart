import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../routes/app_pages.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();
  
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (!AuthService.to.isLoggedIn) {
      Get.offNamed(Routes.LOGIN);
      return;
    }
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final result = await _service.getNotifications();
      unreadCount.value = result['unread_count'];
      notifications.assignAll(result['notifications']);
    } catch (e) {
      Get.snackbar("Error", "Could not load notifications");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(NotificationModel notification) async {
    if (notification.isRead) return;
    
    // Optimistic update
    notification.isRead = true;
    notifications.refresh(); 
    unreadCount.value = (unreadCount.value - 1).clamp(0, 999);

    await _service.markAsRead(notification.id);
  }

  Future<void> markAllRead() async {
    await _service.markAllAsRead();
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
  }
}
