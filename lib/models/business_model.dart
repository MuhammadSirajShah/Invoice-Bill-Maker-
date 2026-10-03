class BusinessModel {
  final String businessName;
  final String phone;
  final String email;
  final String address;

  BusinessModel({
    required this.businessName,
    required this.phone,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  factory BusinessModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return BusinessModel(
      businessName: json['businessName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
    );
  }
}