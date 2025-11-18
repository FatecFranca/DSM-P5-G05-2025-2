import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/profile/domain/entities/profile_user.dart';
import 'package:socialapp/features/profile/domain/repos/profile_repo.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_states.dart';
import 'package:socialapp/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;
  final Map<String, ProfileUser> _profileCache = {};

  ProfileCubit({required this.profileRepo, required this.storageRepo})
    : super(ProfileInitial());

  Future<void> fetchUserProfile(String uid, {bool forceRefresh = false}) async {
    try {
      emit(ProfileLoading());
      if (!forceRefresh && _profileCache.containsKey(uid)) {
        emit(ProfileLoaded(_profileCache[uid]!));
        return;
      }

      final user = await profileRepo.fetchUserProfile(uid);
      if (user != null) {
        _profileCache[uid] = user;
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<ProfileUser?> getUserProfile(
    String uid, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _profileCache.containsKey(uid)) {
      return _profileCache[uid];
    }

    final user = await profileRepo.fetchUserProfile(uid);
    if (user != null) {
      _profileCache[uid] = user;
    }
    return user;
  }

  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());

    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("Failed to fetch user for profile update"));
        return;
      }

      String? imageDownloadUrl;

      if (imageWebBytes != null || imageMobilePath != null) {
        if (imageMobilePath != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
            imageMobilePath,
            uid,
          );
        } else if (imageWebBytes != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(
            imageWebBytes,
            uid,
          );
        }
        if (imageDownloadUrl == null) {
          emit(ProfileError("Failed to upload image"));
          return;
        }
      }

      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      await profileRepo.updateProfile(updatedProfile);

      _profileCache[uid] = updatedProfile;
      await fetchUserProfile(uid, forceRefresh: true);
    } catch (e) {
      emit(ProfileError("Error updating profile: $e"));
    }
  }

  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId);
    } catch (e) {
      emit(ProfileError("Error toggling follow: $e"));
    }
  }

  /// Delega para o repositório a execução da predição de vício.
  Future<Map<String, dynamic>?> predictAddiction(String userId) async {
    try {
      return await profileRepo.predictAddiction(userId);
    } catch (e) {
      // não emite estado específico aqui; repassa erro para quem chamou
      rethrow;
    }
  }
}
