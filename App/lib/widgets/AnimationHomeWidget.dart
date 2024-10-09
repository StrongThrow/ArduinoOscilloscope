import 'package:flutter/material.dart';

class SimpleAnimatedCardItem extends StatefulWidget {
  final String image;
  final Animation<double> animation;
  final bool isSelected;  // 카드가 확장되었는지를 나타내는 변수
  final VoidCallback onTap;  // 사용자가 탭할 때 호출될 콜백 함수
  final double maxWidth;  // 확장 카드 너비
  final double minWidth; // 일반 카드 너비
  final double height; // 카드의 높이
  final Color color;

  const SimpleAnimatedCardItem({
    super.key,
    required this.image,
    required this.animation,
    required this.isSelected,
    required this.onTap,
    required this.maxWidth,
    required this.minWidth,
    required this.height,
    required this.color
  });

  @override
  State<SimpleAnimatedCardItem> createState() => _SimpleAnimatedCardItemState();
}

class _SimpleAnimatedCardItemState extends State<SimpleAnimatedCardItem> {
  bool shouldRect = false;  // 애니메이션을 적용할지 여부를 나타내는 변수, 기본값은 false

  @override
  void didUpdateWidget(covariant SimpleAnimatedCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      // 상태가 변경되었으면 애니메이션을 적용해야 하므로 true로 설정
      shouldRect = true;
    } else {
      // 상태가 변경되지 않았으면 애니메이션을 적용하지 않음
      shouldRect = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            // shouldRect가 true이면, 카드가 확장/축소 상태에 맞춰 애니메이션 값을 계산
            double value = shouldRect
                ? widget.isSelected
                ? widget.animation.value  // 확장 중일 때 애니메이션 값을 사용
                : 1 - widget.animation.value  // 축소 중일 때 애니메이션 값을 반전하여 사용
                : widget.isSelected
                ? 1  // 이미 확장된 상태면 애니메이션 값을 1로 설정
                : 0; // 이미 축소된 상태면 애니메이션 값을 0으로 설정

            // 애니메이션 값에 따른 확대 효과를 계산
            final double animValue = widget.isSelected
                ? const Interval(0, 0.5, curve: Curves.fastOutSlowIn)
                .transform(value)  // 확장 애니메이션에서 0~0.5의 구간만 사용
                : Interval(0.5, 1, curve: Curves.fastOutSlowIn.flipped)
                .transform(value);  // 축소 애니메이션에서 0.5~1의 구간만 사용

            return Container(
              width: widget.minWidth + animValue * (widget.maxWidth - widget.minWidth),  // 축소된 너비에서 애니메이션 값을 반영한 확장된 너비
              height: widget.height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.minWidth / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 3,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  image: DecorationImage(
                    image: AssetImage(widget.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
