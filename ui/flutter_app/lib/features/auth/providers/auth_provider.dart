import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../models/auth_response.dart';
import '../../../repositories/auth_repository.dart';
import '../../../services/local_storage_service.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthResponse?>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return AuthNotifier(authRepo, storage);
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthResponse?>> {
  AuthNotifier(this._repo, this._storage) : super(const AsyncValue.data(null)) {
    _init();
  }

  final AuthRepository _repo;
  final LocalStorageService _storage;

  void _init() {
    if (_repo.isLoggedIn) {
      state = AsyncValue.data(AuthResponse(
        userId: _storage.userId ?? '',
        email: '',
        token: _storage.token ?? '',
      ));
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final res = await _repo.login(email: email, password: password);
      return res;
    });
  }

  Future<void> register({
    required String email,
    required String username,
    String? firstName,
    String? lastName,
    required String password,
    String? referredByCode,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final res = await _repo.register(
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        password: password,
        referredByCode: referredByCode,
      );
      return res;
    });
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }
}
