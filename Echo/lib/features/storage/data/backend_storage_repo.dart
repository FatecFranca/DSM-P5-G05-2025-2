import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:socialapp/features/storage/domain/storage_repo.dart';
import '../../../config/api_service.dart';

class BackendStorageRepo implements StorageRepo {
  final ApiService apiService = ApiService();
  String? _token;

  void setToken(String token) => _token = token;
  String? get token => _token;

  /*
  
  PROFILE PICTURES - upload e download de imagens de perfil
  
  */

  // upload via bytes (Web ou Mobile)
  @override
  Future<String?> uploadProfileImageWeb(
    Uint8List fileBytes,
    String userId,
  ) async {
    print(
      "BackendStorageRepo - uploadProfileImageWeb called for user: $userId",
    );
    print("BackendStorageRepo - token present: ${_token != null}");
    if (_token == null) return null;

    try {
      final uri = Uri.parse('${ApiService.baseUrl}profile/$userId/upload');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: 'profile.png',
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // upload via path (Mobile)
  @override
  Future<String?> uploadProfileImageMobile(String path, String userId) async {
    if (_token == null) return null;

    try {
      final uri = Uri.parse('${ApiService.baseUrl}profile/$userId/upload');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(await http.MultipartFile.fromPath('file', path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) async =>
      null;

  @override
  Future<String?> uploadPostImageWeb(
    Uint8List fileBytes,
    String fileName,
  ) async => null;

  // Métodos auxiliares removidos pois a lógica foi movida diretamente para uploadProfileImageWeb e uploadProfileImageMobile

  /*
  
  DOWNLOAD DA IMAGEM
  
  */

  Future<Uint8List?> downloadProfileImage(String userId) async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}profile/$userId/image'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
