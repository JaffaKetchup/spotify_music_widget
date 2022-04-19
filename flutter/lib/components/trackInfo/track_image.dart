import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class TrackImage extends StatelessWidget {
  const TrackImage({
    Key? key,
    required this.trackInfo,
    required this.colorMode,
  }) : super(key: key);

  final Map<String, dynamic>? trackInfo;
  final int colorMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: trackInfo == null || trackInfo!['image'] == ''
          ? Icon(
              Icons.help_outline,
              color: colorMode <= 1 ? Colors.white : Colors.black,
              size: 36,
            )
          : FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: trackInfo!['image'],
            ),
    );
  }
}
