import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/post/domain/entities/comment.dart';
import 'package:socialapp/features/post/domain/entities/post.dart';
import 'package:socialapp/features/post/domain/entities/post_image.dart';
import 'package:socialapp/features/post/domain/repos/post_repo.dart';
import 'package:socialapp/features/post/presentation/cubits/post_states.dart';
import 'package:socialapp/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;
  List<Post> _cachedPosts = [];
  bool _hasCachedPosts = false;
  final Map<String, List<PostImage>> _cachedPostImages = {};

  PostCubit({required this.postRepo, required this.storageRepo})
    : super(PostsInitial());

  Future<Post> createPost(Post post) async {
    try {
      emit(PostUploading());
      final createdPost = await postRepo.createPost(post);
      _cachedPosts.insert(0, createdPost);
      _hasCachedPosts = true;
      emit(PostsLoaded(List.from(_cachedPosts)));
      return createdPost;
    } catch (e) {
      emit(PostsError("Error creating post: $e"));
      rethrow;
    }
  }

  Future<List<String>> uploadPostImages(
    String postId,
    List<Uint8List> images,
  ) async {
    try {
      emit(PostUploading());
      final imageIds = await postRepo.uploadPostImages(postId, images);
      final index = _cachedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final updatedPost = _cachedPosts[index].copyWith(imageIds: imageIds);
        _cachedPosts[index] = updatedPost;
        emit(PostsLoaded(List.from(_cachedPosts)));
      } else {
        await fetchAllPosts(forceRefresh: true);
      }
      return imageIds;
    } catch (e) {
      emit(PostsError("Error uploading images: $e"));
      rethrow;
    }
  }

  Future<void> fetchAllPosts({bool forceRefresh = false}) async {
    if (_hasCachedPosts && !forceRefresh) {
      emit(PostsLoaded(List.from(_cachedPosts)));
      return;
    }

    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      _cachedPosts = posts;
      _hasCachedPosts = true;
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Error fetching posts: $e"));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
      _cachedPosts.removeWhere((p) => p.id == postId);
      if (_hasCachedPosts) {
        emit(PostsLoaded(List.from(_cachedPosts)));
      }
    } catch (e) {}
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final index = _cachedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _cachedPosts[index];
        final isLiked = post.likes.contains(userId);
        final updatedLikes = List<String>.from(post.likes);
        if (isLiked) {
          updatedLikes.remove(userId);
        } else {
          updatedLikes.add(userId);
        }
        final updatedPost = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          text: post.text,
          imageIds: post.imageIds,
          timestamp: post.timestamp,
          likes: updatedLikes,
          comments: post.comments,
        );
        _cachedPosts[index] = updatedPost;
      }

      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      final index = _cachedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _cachedPosts[index];
        final isLiked = post.likes.contains(userId);
        final updatedLikes = List<String>.from(post.likes);
        if (isLiked) {
          updatedLikes.add(userId);
        } else {
          updatedLikes.remove(userId);
        }
        final revertedPost = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          text: post.text,
          imageIds: post.imageIds,
          timestamp: post.timestamp,
          likes: updatedLikes,
          comments: post.comments,
        );
        _cachedPosts[index] = revertedPost;
        if (_hasCachedPosts) {
          emit(PostsLoaded(List.from(_cachedPosts)));
        }
      }
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      final index = _cachedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _cachedPosts[index];
        final updatedComments = List<Comment>.from(post.comments)..add(comment);
        final updatedPost = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          text: post.text,
          imageIds: post.imageIds,
          timestamp: post.timestamp,
          likes: post.likes,
          comments: updatedComments,
        );
        _cachedPosts[index] = updatedPost;
      }

      await postRepo.addComment(postId, comment);
    } catch (e) {
      final index = _cachedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _cachedPosts[index];
        final revertedComments = post.comments
            .where((c) => c.id != comment.id)
            .toList();
        final revertedPost = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          text: post.text,
          imageIds: post.imageIds,
          timestamp: post.timestamp,
          likes: post.likes,
          comments: revertedComments,
        );
        _cachedPosts[index] = revertedPost;
        if (_hasCachedPosts) {
          emit(PostsLoaded(List.from(_cachedPosts)));
        }
      }
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    Comment? deletedComment;
    try {
      final index = _cachedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _cachedPosts[index];
        deletedComment = post.comments.firstWhere(
          (c) => c.id == commentId,
          orElse: () => post.comments.isNotEmpty
              ? post.comments.first
              : Comment(
                  id: commentId,
                  postId: postId,
                  userId: '',
                  userName: '',
                  text: '',
                  timestamp: DateTime.now(),
                ),
        );
        final updatedComments = post.comments
            .where((c) => c.id != commentId)
            .toList();
        final updatedPost = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          text: post.text,
          imageIds: post.imageIds,
          timestamp: post.timestamp,
          likes: post.likes,
          comments: updatedComments,
        );
        _cachedPosts[index] = updatedPost;
      }

      await postRepo.deleteComment(postId, commentId);
    } catch (e) {
      final index = _cachedPosts.indexWhere((p) => p.id == postId);
      if (index != -1 && deletedComment != null) {
        final post = _cachedPosts[index];
        final revertedComments = List<Comment>.from(post.comments)
          ..add(deletedComment);
        final revertedPost = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          text: post.text,
          imageIds: post.imageIds,
          timestamp: post.timestamp,
          likes: post.likes,
          comments: revertedComments,
        );
        _cachedPosts[index] = revertedPost;
        if (_hasCachedPosts) {
          emit(PostsLoaded(List.from(_cachedPosts)));
        }
      }
    }
  }

  Future<List<PostImage>> fetchPostImages(
    String postId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedPostImages.containsKey(postId)) {
      return _cachedPostImages[postId]!;
    }

    try {
      final images = await postRepo.fetchPostImages(postId);
      _cachedPostImages[postId] = images;
      return images;
    } catch (e) {
      emit(PostsError("Failed to fetch post images: $e"));
      return [];
    }
  }

  Future<List<Comment>> fetchPostComments(String postId) async {
    try {
      return await postRepo.fetchPostComments(postId);
    } catch (e) {
      emit(PostsError("Failed to fetch post comments: $e"));
      return [];
    }
  }
}
