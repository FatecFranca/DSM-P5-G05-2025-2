import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/features/post/domain/entities/comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final List<String> imageIds;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageIds,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  Post copyWith({List<String>? imageIds}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      imageIds: imageIds ?? this.imageIds,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
    );
  }

  // convert post -> json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': userName,
      'text': text,
      'imageUrl': imageIds.isNotEmpty
          ? imageIds[0]
          : null, // Usando primeira imagem como principal
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  // convert json -> post
  factory Post.fromJson(Map<String, dynamic> json) {
    // prepare comments (handle null, list or other types)
    List<Comment> comments = [];
    final commentsRaw = json['comments'];
    if (commentsRaw is List) {
      try {
        comments = commentsRaw
            .map(
              (commentJson) =>
                  Comment.fromJson(commentJson as Map<String, dynamic>),
            )
            .toList();
      } catch (_) {
        comments = [];
      }
    } else {
      comments = [];
    }

    final imageUrlRaw = json['imageUrl'];
    final List<String> imageIds = [];
    if (imageUrlRaw != null) {
      imageIds.add(imageUrlRaw.toString());
    }

    final id = json['id']?.toString() ?? '';
    final userId = json['userId']?.toString() ?? '';
    final userName = json['name']?.toString() ?? '';
    final text = json['text']?.toString() ?? '';

    DateTime timestamp;
    final rawTimestamp =
        json['createdAt'] ?? json['timestamp']; // tenta createdAt primeiro
    if (rawTimestamp is Timestamp) {
      timestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      try {
        timestamp = DateTime.parse(rawTimestamp);
      } catch (e) {
        timestamp = DateTime.now();
      }
    } else {
      timestamp = DateTime.now();
    }

    // Tratar likes - pode ser List<dynamic> ou int (contagem)
    List<String> likes = [];
    final rawLikes = json['likes'];
    if (rawLikes is List) {
      likes = rawLikes
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      imageIds: imageIds,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
    );
  }
}
