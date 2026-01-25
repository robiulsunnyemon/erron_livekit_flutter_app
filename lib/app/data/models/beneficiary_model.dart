class BeneficiaryModel {
  final String id;
  final String method;
  final Map<String, dynamic> details;
  final bool isActive;
  final DateTime createdAt;

  BeneficiaryModel({
    required this.id,
    required this.method,
    required this.details,
    required this.isActive,
    required this.createdAt,
  });

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json) {
    return BeneficiaryModel(
      id: json['id'] ?? "",
      method: json['method'] ?? "",
      details: json['details'] ?? {},
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'details': details,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  String get displayAccount {
    if (method == "bank_transfer") {
      return details['account_number'] != null 
          ? "****${details['account_number'].toString().substring(details['account_number'].toString().length - 4)}"
          : "Bank Account";
    }
    return details['email'] ?? method;
  }
}
