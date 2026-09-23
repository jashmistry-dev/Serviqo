import 'package:equatable/equatable.dart';

class CustomerProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? alternatePhone;
  final String? cityId;
  final String? cityName;
  final String? addressLine1;
  final String? addressLine2;
  final String? pincode;
  final double? latitude;
  final double? longitude;

  const CustomerProfileEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.alternatePhone,
    this.cityId,
    this.cityName,
    this.addressLine1,
    this.addressLine2,
    this.pincode,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        phone,
        alternatePhone,
        cityId,
        cityName,
        addressLine1,
        addressLine2,
        pincode,
        latitude,
        longitude,
      ];
}
