class Address {
  final int id;
  final int userId;
  final String recipientName;
  final String phoneNumber;
  final String addressLine1;
  final String city;
  final String state;
  final String postalCode;
  final bool isDefault;
  final ShippingRate? shippingRate;

  Address({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.isDefault,
    this.shippingRate,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['ID'] ?? 0,
      userId: json['UserID'] ?? 0,
      recipientName: json['RecipientName'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? '',
      addressLine1: json['AddressLine1'] ?? '',
      city: json['City'] ?? '',
      state: json['State'] ?? '',
      postalCode: json['PostalCode']?.toString() ?? '',
      isDefault: json['IsDefault'] ?? false,
      shippingRate: null,
    );
  }

  Address copyWith({ShippingRate? shippingRate}) {
    return Address(
      id: id,
      userId: userId,
      recipientName: recipientName,
      phoneNumber: phoneNumber,
      addressLine1: addressLine1,
      city: city,
      state: state,
      postalCode: postalCode,
      isDefault: isDefault,
      shippingRate: shippingRate ?? this.shippingRate,
    );
  }
}

class ShippingRate {
  final int id;
  final int cityId;
  final int price;

  ShippingRate({
    required this.id,
    required this.cityId,
    required this.price,
  });

  factory ShippingRate.fromJson(Map<String, dynamic> json) {
    return ShippingRate(
      id: json['ID'] ?? 0,
      cityId: json['cityId'] ?? 0,
      price: json['price'] ?? 0,
    );
  }
}
