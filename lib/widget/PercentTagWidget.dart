// ignore_for_file: file_names

import 'package:flutter/material.dart';

class PercentTagWidget extends StatelessWidget {
  /// 控件可见性
  final bool offstage;

  /// 提示信息
  final String message;
  const PercentTagWidget(
      {super.key, required this.offstage, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Offstage(
        offstage: offstage,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          child: Text(message,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}
