import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:socialapp/features/post/domain/entities/post.dart';
import 'package:socialapp/features/post/domain/entities/comment.dart';
import 'package:socialapp/features/post/domain/repos/post_repo.dart';
import '../../../config/api_service.dart';

class BackendPostRepo implements PostRepo {
  final ApiService apiService = ApiService();
  String? _token;

  void setToken(String token) => _token = token;
  String? get token => _token;

  @override
  Future<Post> createPost(Post post) async {
    if (_token == null) throw Exception("Não autorizado");

    try {
      final data = {"text": post.text};

      final response = await apiService.post('posts', data, token: _token);

      return Post.fromJson(response);
    } catch (e) {
      throw Exception("Erro ao criar post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    if (_token == null) throw Exception("Não autorizado");

    try {
      final numericPostId = int.parse(postId);
      await apiService.delete('posts/$numericPostId', token: _token);
    } catch (e) {
      throw Exception("Erro ao deletar post: $e");
    }
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    if (_token == null) return [];

    try {
      final data = await apiService.get('posts', token: _token);
      final posts = (data as List)
          .map((p) => Post.fromJson(p as Map<String, dynamic>))
          .toList();
      return posts;
    } catch (e) {
      throw Exception("Erro ao buscar posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    if (_token == null) return [];

    try {
      final data = await apiService.get('profile/$userId/posts', token: _token);
      final posts = (data as List)
          .map((p) => Post.fromJson(p as Map<String, dynamic>))
          .toList();
      return posts;
    } catch (e) {
      throw Exception("Erro ao buscar posts do usuário: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    if (_token == null) throw Exception("Não autorizado");

    try {
      final numericPostId = int.parse(postId);
      await apiService.post('posts/$numericPostId/like', {}, token: _token);
    } catch (e) {
      try {
        final numericPostId = int.parse(postId);
        await apiService.delete('posts/$numericPostId/unlike', token: _token);
      } catch (e2) {
        throw Exception("Erro ao alternar like: $e2");
      }
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    if (_token == null) throw Exception("Não autorizado");
    try {
      final numericPostId = int.parse(postId);
      await apiService.post(
        'posts/$numericPostId/comments',
        comment.toJson(),
        token: _token,
      );
    } catch (e) {
      throw Exception("Erro ao adicionar comentário: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    if (_token == null) throw Exception("Não autorizado");

    try {
      final numericPostId = int.parse(postId);
      final numericCommentId = int.parse(commentId);
      await apiService.delete(
        'posts/$numericPostId/comments/$numericCommentId',
        token: _token,
      );
    } catch (e) {
      throw Exception("Erro ao deletar comentário: $e");
    }
  }

  @override
  Future<List<String>> uploadPostImages(
    String postId,
    List<Uint8List> images,
  ) async {
    if (_token == null) throw Exception("Não autorizado");
    if (images.isEmpty) return [];

    // Converter o ID do post para número
    final numericPostId = int.parse(postId);
    final uri = Uri.parse('${ApiService.baseUrl}posts/$numericPostId/upload');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $_token';

    // Upload todas as imagens
    for (var i = 0; i < images.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          images[i],
          filename: 'image_$i.png',
        ),
      );
    }

    final response = await request.send();

    final responseData = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao enviar imagens do post: ${response.statusCode} | body: $responseData',
      );
    }
    final List<dynamic> imagesData = jsonDecode(responseData) as List<dynamic>;

    return imagesData.map((imageData) => imageData['id'].toString()).toList();
  }
}
