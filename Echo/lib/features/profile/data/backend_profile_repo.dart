import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:socialapp/features/profile/domain/entities/profile_user.dart';
import 'package:socialapp/features/profile/domain/repos/profile_repo.dart';
import '../../../config/api_service.dart';

class BackendProfileRepo implements ProfileRepo {
  final ApiService apiService = ApiService();
  String? _token;

  void setToken(String token) => _token = token;

  String? get token => _token;

  @override
  Future<ProfileUser?> fetchUserProfile(String userId) async {
    if (_token == null) return null;

    try {
      final data = await apiService.get('profile/$userId', token: _token);
      return ProfileUser.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileUser profile) async {
    if (_token == null) return;
    final data = {"fullname": profile.name, "bio": profile.bio};
    try {
      await apiService.put('profile/${profile.uid}', data, token: _token);
    } catch (e) {
      throw Exception('Erro ao atualizar perfil');
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    if (_token == null) return;

    try {
      await apiService.post('profile/$targetUid/follow', {}, token: _token);
    } catch (e) {
      try {
        await apiService.post('profile/$targetUid/unfollow', {}, token: _token);
      } catch (e2) {
        throw Exception('Erro ao alternar follow');
      }
    }
  }

  Future<void> uploadProfilePicture(String userId, Uint8List fileBytes) async {
    if (_token == null) return;

    final uri = Uri.parse('${ApiService.baseUrl}profile/$userId/upload');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: 'profile.png'),
    );

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Falha ao enviar imagem de perfil');
    }
  }

  @override
  Future<Map<String, dynamic>?> predictAddiction(String userId) async {
    try {
      final data = await apiService.get('ai/predict/$userId', token: _token);
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
