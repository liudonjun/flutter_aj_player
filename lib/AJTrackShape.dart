// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AJTrackShape extends RoundedRectSliderTrackShape {
  const AJTrackShape();

  ///parentBox: 滑块的父级容器的 RenderBox。
  ///offset: 轨道的位置偏移。
  ///sliderTheme: 滑块的主题数据，可以包含轨道的高度等信息。
  ///isEnabled: 是否启用滑块。
  ///isDiscrete: 是否是离散滑块。

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackWidth = parentBox.size.width;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
