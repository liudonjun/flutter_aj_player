// ignore_for_file: file_names
import 'dart:ui' as ui;
import 'package:aj_player/AJPlayerUtils.dart';
import 'package:aj_player/AJThumbImage.dart';
import 'package:aj_player/AJTrackShape.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ButtonControlsWidget extends StatefulWidget {
  /// 播放器控制器
  final VideoPlayerController controller;

  /// 动画控制器
  final AnimationController animationController;

  /// 控件可见性
  final bool controlsVisible;

  /// 自定义拖拽图标
  final ui.Image customImage;

  /// 进度条拖拽中触发
  final Function onChanged;

  /// 进度条拖拽结束时触发
  final Function onChangeEnd;

  /// 进度条位置
  final double progressValue;

  const ButtonControlsWidget(
      {super.key,
      required this.animationController,
      required this.controller,
      required this.controlsVisible,
      required this.customImage,
      required this.onChangeEnd,
      required this.progressValue,
      required this.onChanged});

  @override
  State<ButtonControlsWidget> createState() => _ButtonControlsWidgetState();
}

class _ButtonControlsWidgetState extends State<ButtonControlsWidget> {
  bool get _isFullScreen =>
      MediaQuery.of(context).orientation == Orientation.landscape;
  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        bottom: 0,
        right: 0,
        child: ClipRect(
          child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // 开始位置（隐藏）
                end: const Offset(0, 0), // 结束位置（可见）
              ).animate(widget.animationController),
              child: Container(
                height: 50, // Adjust the height as needed
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    // 来点黑色到透明的渐变优雅一下
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromRGBO(0, 0, 0, .7),
                      Color.fromRGBO(0, 0, 0, 0)
                    ],
                  ),
                ), // Add some background color
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (widget.controller.value.isPlaying) {
                          widget.controller.pause();
                        } else {
                          widget.controller.play();
                        }
                        if (widget.controlsVisible) {
                          widget.animationController
                              .forward(); // Slide down animation
                        } else {
                          widget.animationController
                              .reverse(); // Slide up animation
                        }
                      },
                      icon: Icon(
                        widget.controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AJPlayerUtils.formatDuration(
                          widget.controller.value.position),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 8,
                          inactiveTrackColor: Colors.grey,
                          activeTrackColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          thumbShape: AJThumbImage(image: widget.customImage),
                          trackShape: const AJTrackShape(),
                        ),
                        child: Slider(
                          value: widget.progressValue,
                          onChanged: (value) {
                            widget.onChanged(value);
                          },
                          onChangeEnd: (value) {
                            widget.onChangeEnd(value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AJPlayerUtils.formatDuration(
                          widget.controller.value.duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        if (_isFullScreen) {
                          AJPlayerUtils.setPortrait();
                        } else {
                          AJPlayerUtils.setLandscape();
                        }
                      },
                      icon: Icon(
                        _isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}
