import 'package:flutter/material.dart';

class TrackArtists extends StatelessWidget {
  const TrackArtists({
    Key? key,
    required this.trackInfo,
    required this.colorMode,
  }) : super(key: key);

  final Map<String, dynamic>? trackInfo;
  final int colorMode;

  @override
  Widget build(BuildContext context) {
    return Text(
      'by ' +
          ((trackInfo?['artists'] ?? '') == ''
              ? 'Unknown Artist'
              : trackInfo!['artists']),
      style: TextStyle(
        color: colorMode <= 1 ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      textAlign: TextAlign.right,
    );
  }
}
