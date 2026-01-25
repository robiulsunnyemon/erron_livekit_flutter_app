import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/beneficiary_model.dart';
import '../models/payout_model.dart';

class FinanceService extends GetxService {
  static FinanceService get to => Get.find();
  final AuthService _auth = AuthService.to;

  static const String baseUrl = AuthService.baseUrl;

  Future<List<BeneficiaryModel>> getBeneficiaries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/finance/beneficiaries'),
        headers: {'Authorization': 'Bearer ${_auth.token}'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => BeneficiaryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<BeneficiaryModel?> addBeneficiary(String method, Map<String, String> details) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/finance/beneficiaries'),
        headers: {
          'Authorization': 'Bearer ${_auth.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'method': method,
          'details': details,
        }),
      );

      if (response.statusCode == 201) {
        return BeneficiaryModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<PayoutRequestModel?> requestPayout(double amountCoins, String beneficiaryId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/finance/payout/request'),
        headers: {
          'Authorization': 'Bearer ${_auth.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount_coins': amountCoins,
          'beneficiary_id': beneficiaryId,
        }),
      );

      if (response.statusCode == 201) {
        return PayoutRequestModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['detail'] ?? "Failed to request payout");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      return null;
    }
  }
}
