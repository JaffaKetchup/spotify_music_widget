@echo off
pyinstaller --noconfirm --onefile --windowed --add-data "flutter/build/windows/runner/Release;app/" --icon "flutter/windows/runner/resources/symbol.ico" --distpath "output/"  "python/Spotify Widget.py" | more
rmdir /s /q build
del /q "Spotify Widget.spec"
rmdir /s /q "flutter/symbols"