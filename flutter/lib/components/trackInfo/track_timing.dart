import 'package:flutter/material.dart';

import '../../exts.dart';

class TrackTiming extends StatelessWidget {
  const TrackTiming({
    Key? key,
    required this.elapsedTime,
    required this.trackInfo,
    required this.colorMode,
  }) : super(key: key);

  final Duration elapsedTime;
  final Map<String, dynamic>? trackInfo;
  final int colorMode;

  @override
  Widget build(BuildContext context) {
    return Text(
      elapsedTime.formatAsMinsSecs() +
          ' / ' +
          Duration(milliseconds: trackInfo?['timing']['duration'] ?? 0)
              .formatAsMinsSecs(),
      style: TextStyle(
        color: colorMode <= 1 ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      textAlign: TextAlign.right,
    );
  }
}
