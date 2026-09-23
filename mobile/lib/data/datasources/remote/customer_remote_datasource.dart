import 'package:dio/dio.dart';
import '../../models/category/category_model.dart';
import '../../models/city/city_model.dart';
import '../../models/customer/customer_profile_model.dart';

abstract class CustomerRemoteDatasource {
  Future<List<CategoryModel>> getCategories();
  Future<List<CityModel>> getCities();
  Future<CustomerProfileModel> getProfile();
  Future<CustomerProfileModel> updateProfile(Map<String, dynamic> data);
}

class CustomerRemoteDatasourceImpl implements CustomerRemoteDatasource {
  final Dio _dio;

  CustomerRemoteDatasourceImpl(this._dio);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('/categories');
    final data = response.data['data'] as Map<String, dynamic>;
    final list = data['categories'] as List<dynamic>;
    return list.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CityModel>> getCities() async {
    final response = await _dio.get('/cities');
    final data = response.data['data'] as Map<String, dynamic>;
    final list = data['cities'] as List<dynamic>;
    return list.map((item) => CityModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<CustomerProfileModel> getProfile() async {
    final response = await _dio.get('/customer/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return CustomerProfileModel.fromJson(data);
  }

  @override
  Future<CustomerProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/customer/profile', data: data);
    final responseData = response.data['data'] as Map<String, dynamic>;
    return CustomerProfileModel.fromJson(responseData);
  }
}
