import 'package:socialapp/features/auth/domain/entities/app_user.dart';
import 'package:socialapp/features/auth/domain/repos/auth_repo.dart';
import '../../../config/api_service.dart';

class BackendAuthRepo implements AuthRepo {
  final ApiService apiService = ApiService();
  String? _token;

  @override
  void logout() {
    _token = null;
  }

  @override
  Future<AppUser?> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
    String birthDate,
  ) async {
    final data = await apiService.post('auth/signup', {
      'username': name,
      'password': password,
      'email': email,
      'dateOfBirth': birthDate,
    });

    return AppUser.fromJson(data);
  }

  @override
  Future<AppUser?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final data = await apiService.post('auth/login', {
      'email': email,
      'password': password,
    });
    print("BackendAuthRepo - Login response data: $data");
    final tokenCandidate = data['token'] ?? data['access_token'];
    print("BackendAuthRepo - Token candidate: $tokenCandidate");
    if (tokenCandidate != null) {
      if (tokenCandidate is String) {
        _token = tokenCandidate;
        print("BackendAuthRepo - Set token from string: $_token");
      } else if (tokenCandidate is Map && tokenCandidate['token'] != null) {
        _token = tokenCandidate['token'];
        print("BackendAuthRepo - Set token from map: $_token");
      }
    } else {
      print("BackendAuthRepo - Warning: No token found in response");
    }

    final userData = data['user'] ?? data;

    try {
      return AppUser.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_token == null) return null;

    final data = await apiService.get('/me', token: _token);
    return AppUser.fromJson(data);
  }

  String? get token => _token;
}
