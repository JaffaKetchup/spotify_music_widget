import 'package:flutter/material.dart';

import '../outlined_text.dart';

class TrackName extends StatelessWidget {
  const TrackName({
    Key? key,
    required this.trackInfo,
    required this.colorMode,
  }) : super(key: key);

  final Map<String, dynamic>? trackInfo;
  final int colorMode;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: OutlinedText(
          trackInfo?['name'] ?? 'Unknown',
          key: ValueKey<String?>(trackInfo?['name']),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          strokeColor: colorMode == 0
              ? Colors.black
              : colorMode == 2
                  ? Colors.white
                  : Colors.transparent,
          strokeWidth: colorMode == 0
              ? 0
              : colorMode == 2
                  ? 0
                  : -1,
          textColor: colorMode <= 1 ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
