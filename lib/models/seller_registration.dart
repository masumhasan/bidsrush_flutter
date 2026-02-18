/// Model for seller registration data
class SellerRegistration {
  String? category;
  List<String>? subcategories;
  String? experienceLevel;
  String? fullName;
  String? address;
  String? address2;
  String? city;
  String? stateProvince;
  String? postalCode;
  String? country;
  String? monthlyIncome;

  SellerRegistration({
    this.category,
    this.subcategories,
    this.experienceLevel,
    this.fullName,
    this.address,
    this.address2,
    this.city,
    this.stateProvince,
    this.postalCode,
    this.country,
    this.monthlyIncome,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'subcategories': subcategories,
      'experienceLevel': experienceLevel,
      'fullName': fullName,
      'address': address,
      'address2': address2,
      'city': city,
      'stateProvince': stateProvince,
      'postalCode': postalCode,
      'country': country,
      'monthlyIncome': monthlyIncome,
    };
  }

  factory SellerRegistration.fromJson(Map<String, dynamic> json) {
    return SellerRegistration(
      category: json['category'],
      subcategories: json['subcategories'] != null 
          ? List<String>.from(json['subcategories']) 
          : null,
      experienceLevel: json['experienceLevel'],
      fullName: json['fullName'],
      address: json['address'],
      address2: json['address2'],
      city: json['city'],
      stateProvince: json['stateProvince'],
      postalCode: json['postalCode'],
      country: json['country'],
      monthlyIncome: json['monthlyIncome'],
    );
  }

  bool get isComplete {
    return category != null &&
        (subcategories != null && subcategories!.isNotEmpty) &&
        experienceLevel != null &&
        fullName != null &&
        address != null &&
        city != null &&
        stateProvince != null &&
        postalCode != null &&
        country != null &&
        monthlyIncome != null;
  }
}
