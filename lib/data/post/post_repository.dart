import "package:template/data/api_requester.dart";
import "package:template/data/post/post.dart";

/// 게시글 도메인의 네트워크 통신을 담당한다.
/// 화면(Screen)은 서버 주소나 JSON 파싱을 몰라도 되고, 이 레포지토리의
/// 메서드만 호출하면 된다. 새 도메인이 생기면 같은 방식으로 레포지토리를 하나 더 만든다.
class PostApi {
  PostApi({ApiRequester? requester}) : _requester = requester ?? ApiRequester();

  final ApiRequester _requester;

  Future<List<Post>> fetchPosts() async {
    final data = await _requester.get("/posts") as List<dynamic>;
    return data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Post> fetchPost(int id) async {
    final data = await _requester.get("/posts/$id") as Map<String, dynamic>;
    return Post.fromJson(data);
  }
}
