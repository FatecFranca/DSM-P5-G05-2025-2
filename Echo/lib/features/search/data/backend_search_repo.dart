import 'package:socialapp/features/profile/domain/entities/profile_user.dart';
import 'package:socialapp/features/search/domain/search_repo.dart';
import '../../../config/api_service.dart';

class BackendSearchRepo implements SearchRepo {
  final ApiService apiService = ApiService();
  String? _token;

  void setToken(String token) => _token = token;
  String? get token => _token;

  @override
  Future<List<ProfileUser?>> searchUsers(String query) async {
    if (_token == null) return [];

    try {
      final encoded = Uri.encodeQueryComponent(query);
      final data = await apiService.get(
        'profile/search?keyword=$encoded',
        token: _token,
      );

      if (data == null) return [];

      if (data is List) {
        return data.map((e) {
          final map = _normalizeUserMap(e as Map<String, dynamic>);
          return ProfileUser.fromJson(map);
        }).toList();
      }

      if (data is Map && data['results'] is List) {
        return (data['results'] as List).map((e) {
          final map = _normalizeUserMap(e as Map<String, dynamic>);
          return ProfileUser.fromJson(map);
        }).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}

Map<String, dynamic> _normalizeUserMap(Map<String, dynamic> src) {
  final normalized = <String, dynamic>{};

  normalized['uid'] = src['uid'] ?? src['id'] ?? src['userId'] ?? '';
  normalized['email'] = src['email'] ?? '';
  normalized['name'] =
      src['name'] ?? src['username'] ?? normalized['email'] ?? '';
  normalized['bio'] = src['bio'] ?? '';
  normalized['followers'] = src['followers'] ?? [];
  normalized['following'] = src['following'] ?? [];

  return normalized;
}
