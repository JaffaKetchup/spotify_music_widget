# spotify_music_widget

A simple transparent widget to display information about the currently playing Spotify track. Uses Python and Flutter behind the scenes!

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N4N151INN)

## Building, Setup, and Usage

### Building (from source)

If you need to change any code, you'll need to build from source. This will require an installation of Python 3, Dart, and Flutter on your system (and their dependencies).

Clone this repository into a local directory. Make any changes you need to the scripts. Note that I cannot provide support for altered sources.  
To test changes, the 'py.bat' script will launch the Python script without automatically launching the Flutter app. Running the Flutter app will not start the Python server. If you run 'python/Spotify Widget.py' by itself, it will try (and fail) to launch the Flutter app, so this should not be run during development.  
To build the final executable to 'output/', run 'compile.bat'.

See next section for how to start the executable.

### Setup (with pre-compiled executable)

You can use the executable located at '/output/Spotify Widget.exe' on any Windows 10 system - you shouldn't need any other programs.

Simply download it and run it in a non-privileged location inside another appropriate folder.  
On first run, it will create a 'credentials' directory containing two files. You should populate these files with their respective strings from your Spotify Developer App (<https://developer.spotify.com/dashboard/applications>). This is free, and practically unlimited for personal use - you don't need any special permissions.  
On the next run, it should open a website requesting permission to connect your Spotify account to your app: you should accept this. After that, the program should all be configured, and it should run as normal!

See next section on how to use the executable.

### Usage

Make sure you have followed the Setup instructions, even if you're building from source.

Simply play any track (local files supported) on Spotify, and it will appear in the widget on the top right of your screen. If the window is invisible but your taskbar shows the open program, just wait until the current song ends and you will see it working normally.  
You can then use the Keyboard Shortcuts below to personalise the program.

You should close the program by right clicking on the taskbar icon; never kill the process using Task Manager, as this will not kill the Python backend process.

#### Keyboard Shortcuts

To keep a minimal interface, the Flutter app uses keyboard shortcuts to change it's functionality instead of a settings page. A list of these is provided for ease of use:

- Ctrl + T: Toggle 'Keep On **T**op' functionality (defaults to top)
- Ctrl + V: Toggle whether the window frame and shadow is **v**isible (defaults to invisible)
- Ctrl + M: Toggle whether the window captures the **m**ouse cursor (defaults to capturing)
- C: Loop through the different **c**olor modes - defaults to all white text

The window can be moved around by dragging the very top of a visible, capturing window (highlighted blue at the start of the program). To use the shortcuts, the window needs to be in focus: if the mouse is not being captured, just click the window on the taskbar.

---

## How Does It Work?

The power of Python is used to form a simple 'backend server', which uses the Spotify API (via Spotipy) to get information about your listening session - such as your current or next track.  
The script also starts a Flutter app, which can - much more flexibly than Python can - show this data to you using transparent windows. Python sends this data to Dart/Flutter using an internal socket that is managed for you.  
Both of these are then bundled together with PyInstaller to create one executable that you can run easily. This automatically unpacks all necessary data on each startup, so no installation is needed! This temporary data is then cleared by the OS, or the next time this program runs.

## Notes

- The minimum track length is theoretically unspecified, but glitches may appear when the track is under 40 seconds.
- The program should handle pausing and resuming well. 2 seconds before the end of track widget shows, the remaining time will be recalculated. Skipping will also not break the program.
- Avoid deleting the created 'credentials' directory. This will cause the program to need setting up again.
