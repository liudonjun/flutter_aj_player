// ignore_for_file: file_names

import 'package:flutter/material.dart';

class LinearBufferedWidget extends StatefulWidget {
  final double bufferedValue;
  const LinearBufferedWidget({super.key, required this.bufferedValue});

  @override
  State<LinearBufferedWidget> createState() => _LinearBufferedWidgetState();
}

class _LinearBufferedWidgetState extends State<LinearBufferedWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: ClipRect(
          child: LinearProgressIndicator(
            minHeight: 2,
            value: widget.bufferedValue,
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 109, 107, 107)),
            backgroundColor: Colors.transparent,
          ),
        ));
  }
}
