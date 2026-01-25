import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'auth_service.dart';

class NotificationService {
  final String _baseUrl = AuthService.baseUrl;

  Future<Map<String, dynamic>> getNotifications({int limit = 50, int skip = 0}) async {
    final token = AuthService.to.token;
    if (token == null) throw Exception("Authentication Required");

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/notifications/?limit=$limit&skip=$skip"),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['notifications'];
        final notifications = list.map((e) => NotificationModel.fromJson(e)).toList();
        
        return {
          "unread_count": data['unread_message'],
          "notifications": notifications,
        };
      } else {
        throw Exception("Failed to load notifications: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching notifications: $e");
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final token = AuthService.to.token;
    if (token == null) return;

    try {
      await http.patch(
        Uri.parse("$_baseUrl/notifications/$notificationId/read"),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );
    } catch (e) {
      print("Error marking notification read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    final token = AuthService.to.token;
    if (token == null) return;

    try {
      await http.patch(
        Uri.parse("$_baseUrl/notifications/read-all"),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );
    } catch (e) {
      print("Error marking all read: $e");
    }
  }
}
