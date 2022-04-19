import 'package:flutter/material.dart';

class CommsIndicator extends StatelessWidget {
  const CommsIndicator({
    Key? key,
    required this.show,
  }) : super(key: key);

  final bool show;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: 1,
      width: 1,
      right: 10,
      child: Visibility(
        visible: show,
        child: Container(color: Colors.white),
      ),
    );
  }
}
