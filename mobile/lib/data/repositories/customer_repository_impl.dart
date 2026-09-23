import '../../domain/entities/category_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/customer_profile_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/remote/customer_remote_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDatasource _remoteDatasource;

  CustomerRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return _remoteDatasource.getCategories();
  }

  @override
  Future<List<CityEntity>> getCities() async {
    return _remoteDatasource.getCities();
  }

  @override
  Future<CustomerProfileEntity> getProfile() async {
    return _remoteDatasource.getProfile();
  }

  @override
  Future<CustomerProfileEntity> updateProfile({
    String? name,
    String? phone,
    String? alternatePhone,
    String? cityId,
    String? addressLine1,
    String? addressLine2,
    String? pincode,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (alternatePhone != null) data['alternate_phone'] = alternatePhone;
    if (cityId != null) data['city_id'] = cityId;
    if (addressLine1 != null) data['address_line1'] = addressLine1;
    if (addressLine2 != null) data['address_line2'] = addressLine2;
    if (pincode != null) data['pincode'] = pincode;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    return _remoteDatasource.updateProfile(data);
  }
}
