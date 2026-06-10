/// 서버에서 받은 게시글 한 개를 나타내는 모델.
/// freezed나 json_serializable 없이, JSON Map을 직접 객체로 바꾸는 방식.
/// 새 필드가 생기면 (1) 멤버 변수 (2) [fromJson] (3) [toJson] 세 곳을 함께 고친다.
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  /// JSON Map을 Post 객체로 변환한다. 네트워크 응답을 파싱할 때 쓴다.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"] as int,
      userId: json["userId"] as int,
      title: json["title"] as String,
      body: json["body"] as String,
    );
  }

  /// Post 객체를 JSON Map으로 변환한다. 서버로 보낼 때 쓴다.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "body": body,
    };
  }
}
