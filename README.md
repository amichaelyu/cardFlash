# cardFlash

update icons: 
flutter pub run flutter_launcher_icons:main

android:
flutter build appbundle --no-tree-shake-icons --obfuscate --split-debug-info=build/app/outputs/symbols

ios:
flutter build ipa --no-tree-shake-icons --obfuscate --split-debug-info=build/app/outputs/symbols