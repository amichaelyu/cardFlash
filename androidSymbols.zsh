rm ~/cardFlash/build/app/outputs/bundle/release/Zip.zip
cd /Users/michaelyu/cardFlash/build/app/intermediates/merged_native_libs/release/out/lib
zip "Zip.zip" arm64-v8a armeabi-v7a x86_64
mv Zip.zip ~/cardFlash/build/app/outputs/bundle/release