class PostImage {
  final int id;
  final int postId;
  final String path;

  PostImage({
    required this.id,
    required this.postId,
    required this.path,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      postId: json['postId'] is int
          ? json['postId']
          : int.parse(json['postId'].toString()),
      path: json['path']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'path': path,
    };
  }
}

