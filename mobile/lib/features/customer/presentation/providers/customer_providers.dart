import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/remote/customer_remote_datasource.dart';
import '../../../../data/repositories/customer_repository_impl.dart';
import '../../../../domain/entities/category_entity.dart';
import '../../../../domain/entities/city_entity.dart';
import '../../../../domain/entities/customer_profile_entity.dart';
import '../../../../domain/repositories/customer_repository.dart';

final customerRemoteDatasourceProvider = Provider<CustomerRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return CustomerRemoteDatasourceImpl(dio);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final ds = ref.watch(customerRemoteDatasourceProvider);
  return CustomerRepositoryImpl(ds);
});

/// Fetches real service categories from Laravel backend
final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getCategories();
});

/// Fetches operating cities from Laravel backend
final citiesProvider = FutureProvider<List<CityEntity>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getCities();
});

/// Selected operating city
final selectedCityProvider = StateProvider<CityEntity?>((ref) => null);

/// Customer Profile State Notifier
class CustomerProfileNotifier extends StateNotifier<AsyncValue<CustomerProfileEntity?>> {
  final CustomerRepository _repository;

  CustomerProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? alternatePhone,
    String? cityId,
    String? addressLine1,
    String? addressLine2,
    String? pincode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateProfile(
        name: name,
        phone: phone,
        alternatePhone: alternatePhone,
        cityId: cityId,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        pincode: pincode,
      );
      state = AsyncValue.data(updated);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final customerProfileNotifierProvider =
    StateNotifierProvider<CustomerProfileNotifier, AsyncValue<CustomerProfileEntity?>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerProfileNotifier(repo);
});
