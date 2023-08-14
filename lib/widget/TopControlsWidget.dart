// ignore_for_file: file_names

import 'package:flutter/material.dart';

class TopControlsWidget extends StatefulWidget {
  /// 视频标题
  final String title;

  /// 控件可见性动画控制器
  final AnimationController animationController;

  const TopControlsWidget(
      {super.key, required this.title, required this.animationController});

  @override
  State<TopControlsWidget> createState() => _TopControlsWidgetState();
}

class _TopControlsWidgetState extends State<TopControlsWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: ClipRect(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1), // 开始位置（隐藏）
              end: const Offset(0, 0), // 结束位置（可见）
            ).animate(widget.animationController),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  // 来点黑色到透明的渐变优雅一下
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0),
                    Color.fromRGBO(0, 0, 0, .7)
                  ],
                ),
              ), // Add some background color
              child: Text(
                widget.title, // Replace with your desired title
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ));
  }
}
