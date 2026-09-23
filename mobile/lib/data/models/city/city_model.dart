import '../../../domain/entities/city_entity.dart';

class CityModel extends CityEntity {
  const CityModel({
    required super.id,
    required super.name,
    required super.state,
    required super.pincode,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'pincode': pincode,
    };
  }
}
