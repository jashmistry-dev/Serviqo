import '../entities/category_entity.dart';
import '../entities/city_entity.dart';
import '../entities/customer_profile_entity.dart';

abstract class CustomerRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<CityEntity>> getCities();
  Future<CustomerProfileEntity> getProfile();
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
  });
}
