// ignore_for_file: file_names

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

///自定义的滑块拇指（thumb）外观的类
class AJThumbImage extends SliderComponentShape {
  const AJThumbImage({Key? key, this.image});
  final ui.Image? image;

  ///getPreferredSize: 返回滑块拇指的首选大小。
  ///该方法返回一个零大小的 Size 对象，
  ///这实际上会导致拇指不会显示。你可能会根据需要调整大小。
  ///paint: 用于绘制滑块拇指的外观。在这个方法中，
  ///你可以使用 canvas 对象来绘制任何你想要的图形。
  ///你可以使用 ui.Image 来绘制图像。该方法的参数包含了用于控制绘制的各种参数，
  ///如激活动画、启用动画、大小、样式等。

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(0, 0);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    final imageWidth = image?.width ?? 10;
    final imageHeight = image?.height ?? 10;
    Offset imageOffset = Offset(
      center.dx - imageWidth * 0.5,
      center.dy - imageHeight * 0.5 - 2,
    );
    if (image != null) {
      canvas.drawImage(image!, imageOffset, Paint());
    }
  }
}
