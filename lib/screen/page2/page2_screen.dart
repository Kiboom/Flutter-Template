import "package:flutter/material.dart";
import "package:template/core/theme.dart";
import "package:template/data/post/post.dart";
import "package:template/data/post/post_repository.dart";

/// Page1에서 탭한 항목의 상세 화면. 넘겨받은 [postId]로 서버에서 글 하나를 다시 받아온다.
/// 라우트에서 경로 파라미터(:id)를 받아 화면으로 전달하는 흐름을 보여준다.
class Page2Screen extends StatefulWidget {
  const Page2Screen({super.key, required this.postId});

  final int postId;

  @override
  State<Page2Screen> createState() => _Page2ScreenState();
}

class _Page2ScreenState extends State<Page2Screen> {
  final PostApi _repository = PostApi();
  bool _isLoading = true;
  Object? _error;
  Post? _post;

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
      final post = await _repository.fetchPost(widget.postId);
      if (!mounted) return;
      setState(() {
        _post = post;
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
      appBar: AppBar(title: const Text("Page 2")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _post == null) {
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
    final post = _post!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            post.body,
            style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.gray900),
          ),
        ],
      ),
    );
  }
}
