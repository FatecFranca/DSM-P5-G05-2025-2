import 'dart:typed_data';

abstract class StorageRepo {
  // upload profile images on mobile platforms
  Future<String?> uploadProfileImageMobile(String path, String fileName);

  // upload images on web platforms
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName);

  // upload post images on mobile platforms
  Future<String?> uploadPostImageMobile(String path, String fileName);

  // upload post on web platforms
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName);


}
