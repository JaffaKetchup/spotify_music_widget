@echo off
cd flutter
flutter clean | more
flutter build windows --split-debug-info=symbols | more
cd ..
bundleOnly | more