import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialapp/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "profile_images");
  }

  /*
  
  HELPER METHODS - to upload files to storage
  
  */

  // mobile platforms (file)
  Future<String?> _uploadFile(
    String path,
    String fileName,
    String folder,
  ) async {
    try {
      // get file
      final file = File(path);

      // find place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      // upload
      final UploadTask = await storageRef.putFile(file);

      // get image download url
      final downloadUrl = await UploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // web platform (bytes)
  Future<String?> _uploadFileBytes(
    Uint8List fileBytes,
    String fileName,
    String folder,
  ) async {
    try {
      // find place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      // upload
      final UploadTask = await storageRef.putData(fileBytes);

      // get image download url
      final downloadUrl = await UploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
