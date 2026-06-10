import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:template/core/theme.dart";
import "package:template/data/post/post.dart";
import "package:template/screen/common/spring_button.dart";

/// 목록에서 게시글 한 줄을 그리는 위젯. 탭하면 Page2(상세 화면)로 이동한다.
/// 화면을 잘게 위젯으로 쪼개 두면 코드를 읽고 재사용하기 쉬워진다.
class PostTile extends StatelessWidget {
  const PostTile({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return SpringButton(
      onTap: () => context.push("/page2/${post.id}"),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.gray700),
            ),
          ],
        ),
      ),
    );
  }
}
