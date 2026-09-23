import '../../../domain/entities/customer_profile_entity.dart';

class CustomerProfileModel extends CustomerProfileEntity {
  const CustomerProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    super.alternatePhone,
    super.cityId,
    super.cityName,
    super.addressLine1,
    super.addressLine2,
    super.pincode,
    super.latitude,
    super.longitude,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? {};
    final customerMap = json['customer'] as Map<String, dynamic>? ?? {};
    final cityMap = customerMap['city'] as Map<String, dynamic>?;

    return CustomerProfileModel(
      id: customerMap['id'] as String? ?? userMap['id'] as String? ?? '',
      userId: userMap['id'] as String? ?? '',
      name: userMap['name'] as String? ?? '',
      email: userMap['email'] as String? ?? '',
      phone: userMap['phone'] as String? ?? '',
      alternatePhone: customerMap['alternate_phone'] as String?,
      cityId: customerMap['city_id'] as String?,
      cityName: cityMap?['name'] as String?,
      addressLine1: customerMap['address_line1'] as String?,
      addressLine2: customerMap['address_line2'] as String?,
      pincode: customerMap['pincode'] as String?,
      latitude: double.tryParse(customerMap['latitude']?.toString() ?? ''),
      longitude: double.tryParse(customerMap['longitude']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'phone': phone,
      if (alternatePhone != null) 'alternate_phone': alternatePhone,
      if (cityId != null) 'city_id': cityId,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (pincode != null) 'pincode': pincode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
