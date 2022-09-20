# cardFlash

## update icons: 
flutter pub run flutter_launcher_icons:main

## android:
flutter build appbundle --no-tree-shake-icons --obfuscate --split-debug-info=build/app/outputs/symbols

## ios:
flutter build ipa --no-tree-shake-icons --obfuscate --split-debug-info=build/app/outputs/symbols

## android symbols:
Reproduce next steps and this warning will disappear

    Go to [YOUR_PROJECT]\build\app\intermediates\merged_native_libs\release\out\lib

note that 3 folders exist inside

    arm64-v8a
    armeabi-v7a
    x86_64

    Select this 3 folder and create a .zip file. Name doesn't matter.

[PLEASE NOTE THAT I HAVEN'T COMPRESSED THE ./lib FOLDER]

    Upload this new *.zip file as Symbol File.
~