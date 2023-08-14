// ignore_for_file: file_names

import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_orientation/auto_orientation.dart';
import 'package:brightness_volume/brightness_volume.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AJPlayerUtils {
  // 异步加载图片 自定义 拖拽图标
  static Future<ui.Image> loadImage() async {
    ByteData data = await rootBundle.load("assets/images/ic_launcher.png");
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  // 格式化时间
  static String formatDuration(Duration duration) {
    final formatter = DateFormat('mm:ss');
    return formatter.format(DateTime(0, 0, 0, 0, 0, duration.inSeconds));
  }

  // 设置横屏
  static setLandscape() {
    AutoOrientation.landscapeAutoMode();
    // iOS13+横屏时，状态栏自动隐藏，可自定义：https://juejin.cn/post/7054063406579449863
    if (Platform.isAndroid) {
      ///关闭状态栏，与底部虚拟操作按钮
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
  }

  // 设置竖屏
  static setPortrait() {
    AutoOrientation.portraitAutoMode();
    if (Platform.isAndroid) {
      ///显示状态栏，与底部虚拟操作按钮
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    }
  }

  // 获取音量
  static Future<double> getVolume() async {
    return await BVUtils.volume;
  }

  // 设置音量
  static Future<void> setVolume(double volume) async {
    return await BVUtils.setVolume(volume);
  }

  // 获取亮度
  static Future<double> getBrightness() async {
    return await BVUtils.brightness;
  }

  // 设置亮度
  static Future<void> setBrightness(double brightness) async {
    return await BVUtils.setBrightness(brightness);
  }
}
