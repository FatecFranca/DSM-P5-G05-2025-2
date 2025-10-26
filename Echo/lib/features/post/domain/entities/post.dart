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

    // handle image url/id - could be null, string or number
    final imageUrlRaw = json['imageUrl'];
    final List<String> imageIds = [];
    if (imageUrlRaw != null) {
      imageIds.add(imageUrlRaw.toString());
    }

    // Safely convert IDs and fields to strings
    final id = json['id']?.toString() ?? '';
    final userId = json['userId']?.toString() ?? '';
    final userName = json['name']?.toString() ?? '';
    final text = json['text']?.toString() ?? '';

    // Parse timestamp (could be Timestamp or ISO string)
    DateTime timestamp;
    final rawTimestamp = json['timestamp'];
    if (rawTimestamp is Timestamp) {
      timestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      timestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      timestamp = DateTime.now(); // Fallback
    }

    // Ensure likes is a List<String>
    final likes =
        (json['likes'] as List<dynamic>?)
            ?.map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

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
