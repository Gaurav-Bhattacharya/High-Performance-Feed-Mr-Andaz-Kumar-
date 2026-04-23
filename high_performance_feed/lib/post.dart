class Post{
  final String id;
  final String media_thumb_url;
  final String media_mobile_url;
  final String media_raw_url;
  final int like_count;
  final bool isLiked;
  Post({
    required this.id,
    required this.media_thumb_url,
    required this.media_mobile_url,
    required this.media_raw_url,
    this.like_count = 0,
    this.isLiked = false
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      media_thumb_url: json['media_thumb_url'],
      media_mobile_url: json['media_mobile_url'],
      media_raw_url: json['media_raw_url'],
      like_count: json['like_count'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Post copyWith({
    int? like_count,
    bool? isLiked,
  }) {
    return Post(
      id: id ,
      media_thumb_url: media_thumb_url ,
      media_mobile_url: media_mobile_url ,
      media_raw_url: media_raw_url,
      like_count: like_count ?? this.like_count,
      isLiked: isLiked ?? this.isLiked,
    );
  }

}