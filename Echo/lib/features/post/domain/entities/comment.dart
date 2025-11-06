import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });

  // convert comment -> json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final postId = json['postId']?.toString() ?? '';
    final userId = json['userId']?.toString() ?? '';

    String userName = json['userName']?.toString() ?? '';
    if (userName.isEmpty && json.containsKey('name')) {
      userName = json['name']?.toString() ?? '';
    }

    final text = json['text']?.toString() ?? '';

    DateTime timestamp;
    final raw = json['timestamp'];
    if (raw is Timestamp) {
      timestamp = raw.toDate();
    } else if (raw is String) {
      try {
        timestamp = DateTime.parse(raw);
      } catch (e) {
        timestamp = DateTime.now();
      }
    } else {
      timestamp = DateTime.now();
    }

    final comment = Comment(
      id: id,
      postId: postId,
      userId: userId,
      userName: userName,
      text: text,
      timestamp: timestamp,
    );
    return comment;
  }
}
