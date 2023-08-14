// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CenterLockedWidget extends StatefulWidget {
  /// 锁定按钮动画控制器
  final AnimationController lockAnimationController;

  /// 是否是锁定状态
  final bool isLocked;

  /// 锁定按钮点击事件
  final Function onClick;

  const CenterLockedWidget({
    super.key,
    required this.lockAnimationController,
    required this.isLocked,
    required this.onClick,
  });

  @override
  State<CenterLockedWidget> createState() => _CenterLockedWidgetState();
}

class _CenterLockedWidgetState extends State<CenterLockedWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 16,
        child: ClipRect(
            child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0), // 开始位置（隐藏）
            end: const Offset(0, 0), // 结束位置（可见）
          ).animate(widget.lockAnimationController),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                widget.onClick();
                // setState(() {
                //   _isLocked = !_isLocked; // 切换锁定状态
                //   _isLockedControlsVisible = _isLocked; // 锁定状态下显示锁按钮
                // });
                // if (!_isLocked) {
                //   _showControls(); // 解锁时显示控件
                // }

                // if (_isLocked) {
                //   _hideControls(); // 锁定时隐藏控件
                //   _lockAnimationController?.reverse();
                // }
              },
              child: Icon(
                widget.isLocked ? Icons.lock : Icons.lock_open,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        )));
  }
}
