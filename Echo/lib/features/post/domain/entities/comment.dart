import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String text;
  final DateTime timeStamp;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timeStamp,
  });

  // covert comment -> json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'timeStamp': Timestamp.fromDate(timeStamp),
    };
  }

  // convert json -> comment
  factory Comment.fromJson(Map<String, dynamic> json) {
    // Safely convert ids to strings
    final id = json['id']?.toString() ?? '';
    final postId = json['postId']?.toString() ?? '';
    final userId = json['userId']?.toString() ?? '';
    final userName = json['userName']?.toString() ?? '';
    final text = json['text']?.toString() ?? '';

    // Parse timestamp (could be Timestamp or ISO string)
    DateTime timeStamp;
    final raw = json['timeStamp'];
    if (raw is Timestamp) {
      timeStamp = raw.toDate();
    } else if (raw is String) {
      timeStamp = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      timeStamp = DateTime.now();
    }

    return Comment(
      id: id,
      postId: postId,
      userId: userId,
      userName: userName,
      text: text,
      timeStamp: timeStamp,
    );
  }
}
