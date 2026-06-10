import "package:flutter/material.dart";
import "package:template/data/post/post.dart";
import "package:template/data/post/post_repository.dart";
import "package:template/screen/page1/widgets/post_tile.dart";

/// 1번 탭이자 앱의 첫 화면. 서버에서 게시글 목록을 받아와 보여준다.
/// 로딩 / 에러 / 데이터 세 가지 상태를 setState로 다루는 기본 패턴을 담고 있다.
/// 새 화면을 만들 때 이 구조를 복사해서 시작하면 된다.
class Page1Screen extends StatefulWidget {
  const Page1Screen({super.key});

  @override
  State<Page1Screen> createState() => _Page1ScreenState();
}

class _Page1ScreenState extends State<Page1Screen> {
  final PostApi _repository = PostApi();
  bool _isLoading = true;
  Object? _error;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final posts = await _repository.fetchPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page 1")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("문제가 생겼어요"),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text("다시 시도")),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _posts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => PostTile(post: _posts[index]),
      ),
    );
  }
}
