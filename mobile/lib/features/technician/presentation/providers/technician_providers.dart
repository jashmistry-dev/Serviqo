import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/remote/technician_remote_datasource.dart';
import '../../../../data/repositories/technician_repository_impl.dart';
import '../../../../domain/entities/technician_profile_entity.dart';
import '../../../../domain/entities/technician_verification_entity.dart';
import '../../../../domain/repositories/technician_repository.dart';

final technicianRemoteDatasourceProvider = Provider<TechnicianRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return TechnicianRemoteDatasourceImpl(dio);
});

final technicianRepositoryProvider = Provider<TechnicianRepository>((ref) {
  final ds = ref.watch(technicianRemoteDatasourceProvider);
  return TechnicianRepositoryImpl(ds);
});

class TechnicianProfileNotifier extends StateNotifier<AsyncValue<TechnicianProfileEntity?>> {
  final TechnicianRepository _repository;

  TechnicianProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
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
    String? name,
    String? phone,
    String? bio,
    int? experienceYears,
    double? visitingCharge,
    String? cityId,
    String? address,
    String? pincode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateProfile(
        name: name,
        phone: phone,
        bio: bio,
        experienceYears: experienceYears,
        visitingCharge: visitingCharge,
        cityId: cityId,
        address: address,
        pincode: pincode,
      );
      state = AsyncValue.data(updated);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<String?> toggleAvailability(bool isAvailable) async {
    try {
      final current = state.value;
      if (current != null && isAvailable && !current.isVerified) {
        return 'Cannot go online. Technician verification is required before taking service requests.';
      }

      final success = await _repository.toggleAvailability(isAvailable);
      if (current != null) {
        state = AsyncValue.data(
          TechnicianProfileEntity(
            id: current.id,
            userId: current.userId,
            name: current.name,
            email: current.email,
            phone: current.phone,
            bio: current.bio,
            experienceYears: current.experienceYears,
            visitingCharge: current.visitingCharge,
            verificationStatus: current.verificationStatus,
            verificationNotes: current.verificationNotes,
            isAvailable: success,
            cityId: current.cityId,
            cityName: current.cityName,
            ratingAvg: current.ratingAvg,
            ratingCount: current.ratingCount,
            totalCompletedServices: current.totalCompletedServices,
          ),
        );
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final technicianProfileNotifierProvider =
    StateNotifierProvider<TechnicianProfileNotifier, AsyncValue<TechnicianProfileEntity?>>((ref) {
  final repo = ref.watch(technicianRepositoryProvider);
  return TechnicianProfileNotifier(repo);
});

final technicianVerificationsProvider =
    FutureProvider<List<TechnicianVerificationEntity>>((ref) async {
  final repo = ref.watch(technicianRepositoryProvider);
  return repo.getVerifications();
});
