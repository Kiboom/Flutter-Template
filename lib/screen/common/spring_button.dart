import "package:flutter/widgets.dart";
import "package:template/screen/common/haptic_feedback.dart";

/// 누르면 살짝 줄어들었다 돌아오는(스프링) 애니메이션과 햅틱이 붙은 버튼.
/// 일반 버튼 대신 감싸서 쓰면 터치 피드백이 풍부해진다.
/// 예: `SpringButton(onTap: () {}, child: Text("확인"))`
class SpringButton extends StatefulWidget {
  const SpringButton({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.enableHaptic = true,
    this.scaleOnTapped = 0.96,
    this.duration = const Duration(milliseconds: 200),
    this.alignment = Alignment.center,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final bool enableHaptic;
  final double scaleOnTapped;
  final Duration duration;
  final Alignment alignment;

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: widget.scaleOnTapped,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) {
      if (widget.enableHaptic) AppHaptic.error();
      return;
    }
    if (widget.enableHaptic) AppHaptic.selection();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        alignment: widget.alignment,
        child: widget.child,
      ),
    );
  }
}
