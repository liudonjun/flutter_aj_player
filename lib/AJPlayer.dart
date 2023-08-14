// ignore_for_file: file_names, deprecated_member_use

import 'dart:async';
import 'dart:ui' as ui;

import 'package:aj_player/AJPlayerUtils.dart';
import 'package:aj_player/widget/ButtonControlsWidget.dart';
import 'package:aj_player/widget/CenterLockedWidget.dart';
import 'package:aj_player/widget/LinearBufferedWidget.dart';
import 'package:aj_player/widget/PercentTagWidget.dart';
import 'package:aj_player/widget/TopControlsWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class AJPlayer extends StatefulWidget {
  /// 视频标题
  final String title;

  /// 视频播放地址
  final String videoUrl;

  /// 拖拽超出时提示文字
  final String dropText;

  /// 不能超过的进度位置,默认1.0 不限制
  final double? learnProgress;

  /// 是否打开日志，只在debug模式下生效
  final bool? debugLog;

  /// 初始化拇指图标
  final Function? initAJThumb;

  /// 是否需要拇指图标
  final bool? hasAJThumb;

  /// 视频播放完成回调
  final VoidCallback? onPlaybackComplete;

  // 保存widget 实例
  late State<AJPlayer> state;

  AJPlayer(
      {super.key,
      required this.title,
      required this.videoUrl,
      this.dropText = '不能拖拽到未观看的部分',
      this.learnProgress = 1.0,
      this.debugLog = true,
      this.initAJThumb = AJPlayerUtils.loadImage,
      this.hasAJThumb = true,
      this.onPlaybackComplete});

  @override
  // ignore: no_logic_in_create_state
  State<AJPlayer> createState() {
    state = _AJPlayerState();
    return state;
  }

  void switchVideo(String url) {
    playerState?.switchVideo(url);
  }

  // ignore: library_private_types_in_public_api
  _AJPlayerState? get playerState => state as _AJPlayerState?;
}

class _AJPlayerState extends State<AJPlayer> with TickerProviderStateMixin {
  late VideoPlayerController _controller; // 视频播放控制器
  bool _controlsVisible = true; //控件是否可见
  bool _isLoading = true; // 加载视频中
  double _progressValue = 0.0; // 进度条位置

  bool _isDragging = false; // 是否拖拽进度条

  AnimationController? _animationController; // 动画控制器

  AnimationController? _lockAnimationController; // 锁定动画控制器

  Timer? _hideControlsTimer; // 计时器用于自动隐藏控件

  ui.Image? _customImage; // 自定义thumbShape

  bool _isLocked = false; // 初始化锁定状态为 未锁定

  bool _isLockedControlsVisible = false; // 锁定状态下的控件是否可见

  double _brightnessValue = 0.0; // 设备当前的亮度
  double _volumeValue = 0.0; // 设备本身的音量

  Offset? _startPanOffset;

  double _width = 0.0; // 组件宽度
  double _height = 0.0; // 组件高度

  late double _movePan; // 滑动的偏移量累计总和

  bool _brightnessOk = false; // 是否允许调节亮度
  bool _volumeOk = false; // 是否允许调节亮度
  bool _seekOk = false; // 是否允许调节播放进度

  bool _offstage = true; // false 是显示 true 隐藏

  String _percentage = ''; // 提示文字

  Duration _positionValue = const Duration(seconds: 0);

  double _bufferedValue = 0.0; // 缓冲进度

  void log(String msg) {
    if (widget.debugLog!) {
      if (kDebugMode) {
        print('AJLog:$msg');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    /// 初始化拇指按钮
    if (widget.hasAJThumb!) {
      widget.initAJThumb!().then((image) {
        _customImage = image;
        if (!mounted) return;
        setState(() {});
      });
    }

    // 获取音量，亮度
    _setInit();

    // 初始动画控制器时间
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 锁定动画控制器
    _lockAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 初始 播放器控制器
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false; // Video is loaded, hide loading indicator
        });
      });

    // 添加监听
    _controller.addListener(_onControllerUpdate);

    // 启动动画控制器，初始状态是显示底部控件
    _animationController?.forward();
    _lockAnimationController?.forward();

    // 开启自动隐藏控件定时器
    _startHideControlsTimer();
  }

  // 播放器监听函数
  void _onControllerUpdate() {
    if (!_isDragging) {
      if (_controller.value.isPlaying) {
        if (_controlsVisible) {
          _animationController?.forward();
          _showControls(); // 显示控件
        }
      } else {
        if (!_controlsVisible) {
          _animationController?.reverse();
          _hideControls(); // 隐藏控件
        }
      }

      if (_controller.value.duration != Duration.zero) {
        log('缓冲值：$_bufferedValue');

        setState(() {
          // 处理进度条位置
          _progressValue =
              _controller.value.position.inMilliseconds.toDouble() /
                  _controller.value.duration.inMilliseconds.toDouble();
          // 处理缓冲进度
          _bufferedValue = _controller.value.buffered.isNotEmpty
              ? _controller.value.buffered.last.end.inMilliseconds.toDouble() /
                  _controller.value.duration.inMilliseconds.toDouble()
              : 0.0;
        });
      }
      // 播放完成
      if (_controller.value.position == _controller.value.duration) {
        if (widget.onPlaybackComplete != null) {
          widget.onPlaybackComplete!();
        }
      }
    }
  }

  // 初始化获取音量和亮度
  void _setInit() async {
    _volumeValue = await AJPlayerUtils.getVolume();
    _brightnessValue = await AJPlayerUtils.getBrightness();
  }

  // 定时隐藏控件
  void _startHideControlsTimer() {
    // 取消之前的计时器
    _hideControlsTimer?.cancel();

    // 启动新的计时器
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      // 自动隐藏控件
      _hideControls();
      _lockAnimationController?.reverse();
      setState(() {
        _isLockedControlsVisible = true;
      });
    });
  }

  // 隐藏控件
  void _hideControls() {
    if (_controlsVisible) {
      _animationController?.reverse();
      setState(() {
        _controlsVisible = false;
      });
    }
  }

  // 显示控件
  void _showControls() {
    if (!_controlsVisible) {
      _animationController?.forward();
      setState(() {
        _controlsVisible = true;
      });
    }
  }

  // 重置手势
  void _resetPan() {
    _startPanOffset = const Offset(0, 0);
    _movePan = 0;
    _width = context.size!.width;
    _height = context.size!.height;
  }

  void _onVerticalDragEnd(_) {
    if (_isLocked) return;
    // 隐藏
    // _percentageWidget.offstageCallback(true);
    setState(() {
      _offstage = true;
    });
    if (_volumeOk) {
      _volumeValue = _getVolumeValue();
      _volumeOk = false;
    } else if (_brightnessOk) {
      _brightnessValue = _getBrightnessValue();
      _brightnessOk = false;
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isLocked) return;
    // 累计计算偏移量(下滑减少百分比，上滑增加百分比)
    _movePan += (-details.delta.dy);
    if (_startPanOffset!.dx < (_width / 2)) {
      if (_brightnessOk) {
        double b = _getBrightnessValue();
        log("亮度：${(b * 100).toInt()}%");
        setState(() {
          _offstage = false;
          _percentage = "亮度：${(b * 100).toInt()}%";
        });
        // _percentageWidget.percentageCallback("亮度：${(b * 100).toInt()}%");
        AJPlayerUtils.setBrightness(b);
      }
    } else {
      if (_volumeOk) {
        double v = _getVolumeValue();
        log("音量：${(v * 100).toInt()}%");
        setState(() {
          _offstage = false;
          _percentage = "音量：${(v * 100).toInt()}%";
        });
        // _percentageWidget.percentageCallback("音量：${(v * 100).toInt()}%");
        AJPlayerUtils.setVolume(v);
      }
    }
  }

  // 计算亮度百分比
  double _getBrightnessValue() {
    double value = double.parse(
        (_movePan / _height + _brightnessValue).toStringAsFixed(2));
    if (value >= 1.00) {
      value = 1.00;
    } else if (value <= 0.00) {
      value = 0.00;
    }
    return value;
  }

  // 计算声音百分比
  double _getVolumeValue() {
    double value =
        double.parse((_movePan / _height + _volumeValue).toStringAsFixed(2));
    if (value >= 1.0) {
      value = 1.0;
    } else if (value <= 0.0) {
      value = 0.0;
    }
    return value;
  }

  // 计算播放进度百分比
  double _getSeekValue() {
    // 进度条百分控制
    double valueHorizontal =
        double.parse((_movePan / _width).toStringAsFixed(2));
    log('拖拽时长:${_positionValue.inMilliseconds}');
    log('总时长:${_controller.value.duration.inMilliseconds}');
    // 当前进度条百分比
    double currentValue = _positionValue.inMilliseconds /
        _controller.value.duration.inMilliseconds;
    log('当前进度条百分比:$currentValue');
    double value =
        double.parse((currentValue + valueHorizontal).toStringAsFixed(2));
    if (value >= 1.00) {
      value = 1.00;
    } else if (value <= 0.00) {
      value = 0.00;
    }
    return value;
  }

  // 垂直滑动触发
  void _onVerticalDragStart(DragStartDetails details) {
    if (_isLocked) return;
    if (!_controller.value.isInitialized) return;
    _resetPan();
    _startPanOffset = details.globalPosition;
    setState(() {
      _offstage = true;
    });
    if (_startPanOffset!.dx < _width * 0.5) {
      // 左边调整亮度
      log('左边调整亮度');
      _brightnessOk = true;
    } else {
      // 右边调整声音
      _volumeOk = true;
      log('右边调整声音');
    }
  }

  // 暂停 播放
  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _startHideControlsTimer();
    } else {
      _controller.play();
      _startHideControlsTimer();
    }
  }

  /// 水平拖动开始时
  void _onHorizontalDragStart(DragStartDetails details) {
    if (_isLocked) return;
    if (!_controller.value.isInitialized) return;
    log('水平拖动开始位置:${_controller.value.position}');
    _resetPan();
    _positionValue = _controller.value.position;
    _seekOk = true;
  }

  /// 水平拖动开始中
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isLocked) return;
    if (!_seekOk) return;

    double totalWidth = context.size!.width; // 获取视频进度条总宽度
    _movePan += details.delta.dx;

    double newValue =
        (_movePan / totalWidth).clamp(-1.0, 1.0); // 使用 clamp 限制值在 -1 到 1 之间

    // int newPosition = (_positionValue.inMilliseconds +
    //     (newValue * _controller.value.duration.inMilliseconds).toInt());

    // Duration newDuration = Duration(milliseconds: newPosition);

    // 添加边界检查
    double newProgress = (_progressValue + newValue).clamp(0.0, 1.0);
    int newPosition =
        (newProgress * _controller.value.duration.inMilliseconds).toInt();

    if (newProgress > widget.learnProgress!) {
      // 用户拖拽到未学习的部分，更新提示文本
      setState(() {
        _offstage = false;
        _percentage = widget.dropText;
      });
      return; // 阻止进度更新
    }

    Duration newDuration = Duration(milliseconds: newPosition);

    if (newValue >= 0) {
      setState(() {
        _offstage = false;
        _percentage = "快进至：${AJPlayerUtils.formatDuration(newDuration)}";
      });
    } else {
      setState(() {
        _offstage = false;
        _percentage = "快退至：${AJPlayerUtils.formatDuration(newDuration)}";
      });
    }
  }

  /// 水平拖动结束
  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isLocked) return;
    if (!_seekOk) return;
    double value = _getSeekValue();

    double totalWidth = context.size!.width; // 获取视频进度条总宽度
    int newPosition =
        (value * _controller.value.duration.inMilliseconds).toInt();

    double newValue = (_movePan / totalWidth).clamp(-1.0, 1.0);

    // 添加边界检查
    double newProgress = (_progressValue + newValue).clamp(0.0, 1.0);

    if (newProgress > widget.learnProgress!) {
      setState(() {
        _offstage = true;
      });
      return; // 阻止进度更新
    }

    log('newPosition:$newPosition');

    _controller.seekTo(Duration(milliseconds: newPosition));

    _seekOk = false;
    _movePan = 0;
    _positionValue = Duration(milliseconds: newPosition);
    setState(() {
      _offstage = true;
    });
  }

  // 切换视频的方法
  void switchVideo(String newVideoUrl) async {
    // 停止之前的计时器和动画
    _hideControlsTimer?.cancel();
    _animationController?.stop();
    _lockAnimationController?.stop();

    // 重置状态
    setState(() {
      _controlsVisible = true;
      _isLocked = false;
      _isLockedControlsVisible = false;
      _isLoading = true;
      _isDragging = false;
      _progressValue = 0.0;
      _percentage = '';
      _offstage = true;
    });

    // 销毁之前的控制器
    await _controller.dispose();

    // 创建新的播放器控制器
    _controller = VideoPlayerController.network(newVideoUrl)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false; // 视频加载完成，隐藏加载指示器
        });
      });

    // 添加监听
    _controller.addListener(_onControllerUpdate);

    // 重置计时器
    _startHideControlsTimer();

    // 启动动画控制器，初始状态是显示底部控件
    _animationController?.forward();
    _lockAnimationController?.forward();

    setState(() {});
  }

  // 播放器双击
  void _onDoubleTap() {
    if (!_isLocked) {
      _togglePlayPause();
      _showControls();
    }
  }

  // 播放器空白区域单机
  void _onVideoTap() {
    setState(() {
      _isLockedControlsVisible = !_isLockedControlsVisible;
    });
    if (!_isLocked) {
      if (_controlsVisible) {
        _hideControls();
      } else {
        _showControls();
      }
    }
    if (_isLockedControlsVisible) {
      _lockAnimationController?.reverse();
    } else {
      _lockAnimationController?.forward();
    }
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController?.dispose();
    _lockAnimationController?.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      onHorizontalDragStart: _onHorizontalDragStart, // 手势跳转播放起始位置
      onHorizontalDragUpdate: _onHorizontalDragUpdate, // 根据手势更新快进或快退
      onHorizontalDragEnd: _onHorizontalDragEnd, // 手势结束seekTo
      onDoubleTap: _onDoubleTap,
      onTap: _onVideoTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const SizedBox(
                      height: 250,
                    ),
              if (_isLoading ||
                  _controller.value
                      .isBuffering) // Display loading indicator while loading
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
              // 中间播放暂停按钮
              if (!_isLoading && !_controller.value.isBuffering)
                AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: () {
                      if (!_isLocked) {
                        _togglePlayPause();
                        _showControls(); // 点击按钮时显示控件
                      }
                    },
                    child: Visibility(
                        visible: _isLocked ? false : _controlsVisible,
                        child: Container(
                          color: Colors.transparent,
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 60.0,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ),

              // 弹出层控件
              PercentTagWidget(
                message: _percentage,
                offstage: _offstage,
              ),
              // 头部控件
              TopControlsWidget(
                title: widget.title,
                animationController: _animationController!,
              ),
              // 锁
              CenterLockedWidget(
                isLocked: _isLocked,
                lockAnimationController: _lockAnimationController!,
                onClick: () {
                  setState(() {
                    _isLocked = !_isLocked; // 切换锁定状态
                    _isLockedControlsVisible = _isLocked; // 锁定状态下显示锁按钮
                  });
                  if (!_isLocked) {
                    _showControls(); // 解锁时显示控件
                  }

                  if (_isLocked) {
                    _hideControls(); // 锁定时隐藏控件
                    _lockAnimationController?.reverse();
                  }
                },
              ),

              // 底部控件
              ButtonControlsWidget(
                  animationController: _animationController!,
                  controller: _controller,
                  controlsVisible: _controlsVisible,
                  customImage: _customImage!,
                  progressValue: _progressValue,
                  onChangeEnd: (value) {
                    setState(() {
                      _isDragging = false;
                    });
                    if (value > widget.learnProgress! && !_isDragging) {
                      setState(() {
                        _offstage = true;
                      });
                      final newPosition = widget.learnProgress! *
                          _controller.value.duration.inMilliseconds;
                      _controller
                          .seekTo(Duration(milliseconds: newPosition.toInt()));
                      return;
                    }
                    final newPosition =
                        value * _controller.value.duration.inMilliseconds;
                    _controller
                        .seekTo(Duration(milliseconds: newPosition.toInt()));
                  },
                  onChanged: (value) {
                    if (value > widget.learnProgress! && _isDragging) {
                      setState(() {
                        _percentage = "不能拖拽到未学习的部分";
                        _offstage = false;
                        _isDragging = true;
                        _progressValue = widget.learnProgress!;
                      });
                      return;
                    }
                    setState(() {
                      _progressValue = value;
                      _isDragging = true;
                    });
                  }),
              //  缓冲条
              if (_bufferedValue != 1)
                LinearBufferedWidget(
                  bufferedValue: _bufferedValue,
                )
            ],
          ),
        ],
      ),
    );
  }
}
