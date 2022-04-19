import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:keymap/keymap.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import 'comms.dart' as comms;
import 'components/indicator.dart';
import 'components/trackInfo/track_artists.dart';
import 'components/trackInfo/track_image.dart';
import 'components/trackInfo/track_name.dart';
import 'components/trackInfo/track_timing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await windowManager.ensureInitialized();

  await windowManager.setAlwaysOnTop(true);
  await windowManager.setAsFrameless();
  await windowManager.setHasShadow(false);

  await Window.setEffect(
    effect: WindowEffect.transparent,
    color: Colors.transparent,
  );

  doWhenWindowReady(() {
    const initialSize = Size(600, 80);
    appWindow.maxSize = const Size(5000, 80);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.topRight;
    appWindow.title = "Spotify Music Widget";
    appWindow.show();
  });

  runApp(const AppContainer());
}

class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  Color colorOfDraggable = Colors.blue;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3),
        () => setState(() => colorOfDraggable = Colors.transparent));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotify Music Widget',
      home: Column(
        children: [
          SizedBox(
            height: 10,
            child: WindowTitleBarBox(
              child: MoveWindow(
                child: AnimatedContainer(
                  color: colorOfDraggable,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                ),
              ),
            ),
          ),
          const Expanded(child: AppInterface()),
        ],
      ),
    );
  }
}

class AppInterface extends StatefulWidget {
  const AppInterface({Key? key}) : super(key: key);

  @override
  State<AppInterface> createState() => _AppInterfaceState();
}

class _AppInterfaceState extends State<AppInterface> with WindowListener {
  Map<String, dynamic>? trackInfo;
  int currentSecs = 0;
  Duration elapsedTime = const Duration(seconds: 0);

  bool visible = true;
  bool showCommsIndicator = false;

  bool isAlwaysOnTop = true;
  bool isFrameVisible = false;
  bool isMouseCaptured = true;

  int colorMode = 1;

  List<KeyAction> get keyboardActions => [
        KeyAction(
          LogicalKeyboardKey.keyT,
          'Toggle Always On Top',
          () async {
            await windowManager.setAlwaysOnTop(!isAlwaysOnTop);
            isAlwaysOnTop = !isAlwaysOnTop;
          },
          isControlPressed: true,
        ),
        KeyAction(
          LogicalKeyboardKey.keyV,
          'Toggle Frame Visible',
          () async {
            if (isFrameVisible) {
              await windowManager.setAsFrameless();
              await windowManager.setHasShadow(false);
            } else {
              await windowManager.setHasShadow(true);
            }
            isFrameVisible = !isFrameVisible;
          },
          isControlPressed: true,
        ),
        KeyAction(
          LogicalKeyboardKey.keyM,
          'Toggle Mouse Capture',
          () async {
            await windowManager.setIgnoreMouseEvents(isMouseCaptured);
            isMouseCaptured = !isMouseCaptured;
          },
          isControlPressed: true,
        ),
        KeyAction(
          LogicalKeyboardKey.keyC,
          'Change Color Mode',
          () => setState(() => colorMode += (colorMode == 3 ? -3 : 1)),
        ),
      ];

  @override
  void initState() {
    super.initState();

    // Kill Python process on exit (if run from bundle)
    windowManager.addListener(this);
    (() async {
      await windowManager.setPreventClose(true);
      setState(() {});
    })();

    // Listen to the communication socket (127.0.0.1:65535)
    comms.listenToSocket().listen(
      (info) async {
        setState(() {
          trackInfo = info.isEmpty ? null : info;
          currentSecs = 0;
          elapsedTime = const Duration(seconds: 0);
        });
        flashCommsIndicator();
        setTaskbarProgress();
      },
      onError: (e) {
        setState(() => trackInfo = null);
        flashCommsIndicator();
        setTaskbarProgress();
      },
    );

    // Iterate a seconds counter and recalculate visiblity
    Stream.periodic(const Duration(seconds: 1), null).listen(
      (_) {
        setState(() {
          currentSecs++;
          elapsedTime = Duration(
              milliseconds:
                  (trackInfo?['timing']['elapsed'] ?? 0) + currentSecs * 1000);

          visible = elapsedTime.inMilliseconds <= 10000 ||
              ((trackInfo?['timing']['duration'] ?? 0) -
                          elapsedTime.inMilliseconds <=
                      10000 &&
                  (trackInfo?['timing']['duration'] ?? 1) != 0);
        });
        setTaskbarProgress();
      },
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await Process.run('taskkill', ['/f', '/im', 'Spotify Widget.exe']);
    await windowManager.destroy();
  }

  void flashCommsIndicator() async {
    setState(() => showCommsIndicator = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => showCommsIndicator = false);
  }

  void setTaskbarProgress() async {
    if ((trackInfo ?? {}).isEmpty || trackInfo?['timing']['duration'] == 0) {
      await WindowsTaskbar.setProgressMode(TaskbarProgressMode.error);
    } else if (visible) {
      await WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
    } else {
      await WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
      await WindowsTaskbar.setProgress(
          elapsedTime.inMilliseconds, trackInfo?['timing']['duration']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KeyboardWidget(
        bindings: keyboardActions,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            CommsIndicator(show: showCommsIndicator),
            AnimatedPositioned(
              height: appWindow.size.height,
              width: appWindow.size.width,
              top: visible ? 0 : -appWindow.size.height,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                opacity: visible ? 1 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TrackName(
                              trackInfo: trackInfo,
                              colorMode: colorMode,
                            ),
                            TrackArtists(
                              trackInfo: trackInfo,
                              colorMode: colorMode,
                            ),
                            TrackTiming(
                              elapsedTime: elapsedTime,
                              trackInfo: trackInfo,
                              colorMode: colorMode,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        TrackImage(
                          trackInfo: trackInfo,
                          colorMode: colorMode,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
