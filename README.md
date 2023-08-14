# flutter_aj_player

A Flutter video player 🛠 Ready for Android 🚀

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
 flutter_pda_scan: 
  git:
    url: https://github.com/liudonjun/flutter_aj_player
```

## Constructor

```dart

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

```

### Customize Thumb Icon

```dart
// 异步加载图片 自定义 拖拽图标
static Future<ui.Image> loadImage() async {
  ByteData data = await rootBundle.load("assets/images/ic_launcher.png");
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  ui.FrameInfo fi = await codec.getNextFrame();
  return fi.image;
}
```


## example

```dart
import 'package:aj_player/AJPlayer.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: AJPlayer(
        videoUrl:
            'https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4',
        title: '测试标题',
      ),
    );
  }
}


```
### Preview

<img src="./prev.png">


