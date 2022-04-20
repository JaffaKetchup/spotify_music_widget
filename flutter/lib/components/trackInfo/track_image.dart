import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackImage extends StatelessWidget {
  const TrackImage({
    Key? key,
    required this.trackInfo,
    required this.elapsedTime,
    required this.colorMode,
  }) : super(key: key);

  final Map<String, dynamic>? trackInfo;
  final Duration elapsedTime;
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
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: elapsedTime >= const Duration(seconds: 10) &&
                      elapsedTime <= const Duration(seconds: 17) &&
                      trackInfo!['link'] != ''
                  ? GestureDetector(
                      onTap: () async => await launch(trackInfo!['link']),
                      child: QrImage(
                        data: trackInfo!['link'],
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(2),
                      ),
                    )
                  : FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: trackInfo!['image'],
                    ),
            ),
    );
  }
}
