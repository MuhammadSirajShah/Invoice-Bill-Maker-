
class BusinessModel {
  final String businessName;
  final String phone;
  final String email;
  final String address;
  final String? logoPath;

  BusinessModel({
    required this.businessName,
    required this.phone,
    required this.email,
    required this.address,
    this.logoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'phone': phone,
      'email': email,
      'address': address,
      'logoPath': logoPath,
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
      logoPath: json['logoPath'],
    );
  }
}