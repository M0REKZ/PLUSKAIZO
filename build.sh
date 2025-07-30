#!/usr/bin/env bash
cd "$(dirname "$0")"

mkdir -p ./build/bin

#build .love file

zip -r PLUSKAIZO.love ./ -x "./love-bin/**" -x "./build/**" -x "./.git/**" -x "*.DS_Store"

#build macOS

cp -R ./love-bin/bin/love.app/ ./build/bin/PLUSKAIZO.app/
cp ./PLUSKAIZO.love ./build/bin/PLUSKAIZO.app/Contents/Resources/PLUSKAIZO.love
cp ./love-bin/Info.plist ./build/bin/PLUSKAIZO.app/Contents/Info.plist
cp ./love-bin/icon.icns ./build/bin/PLUSKAIZO.app/Contents/Resources/icon.icns

#build Win32

mkdir -p ./build/bin/PLUSKAIZO-Win32

cat ./love-bin/bin/love-11.5-win32/love.exe ./PLUSKAIZO.love > ./build/bin/PLUSKAIZO-Win32/PLUSKAIZO.exe

cp ./love-bin/bin/love-11.5-win32/SDL2.dll ./build/bin/PLUSKAIZO-Win32/SDL2.dll
cp ./love-bin/bin/love-11.5-win32/OpenAL32.dll ./build/bin/PLUSKAIZO-Win32/OpenAL32.dll
cp ./love-bin/bin/love-11.5-win32/license.txt ./build/bin/PLUSKAIZO-Win32/license-love.txt
cp ./love-bin/bin/love-11.5-win32/love.dll ./build/bin/PLUSKAIZO-Win32/love.dll
cp ./love-bin/bin/love-11.5-win32/lua51.dll ./build/bin/PLUSKAIZO-Win32/lua51.dll
cp ./love-bin/bin/love-11.5-win32/mpg123.dll ./build/bin/PLUSKAIZO-Win32/mpg123.dll
cp ./love-bin/bin/love-11.5-win32/msvcp120.dll ./build/bin/PLUSKAIZO-Win32/msvcp120.dll
cp ./love-bin/bin/love-11.5-win32/msvcr120.dll ./build/bin/PLUSKAIZO-Win32/msvcr120.dll

#build linux

7zz x ./love-bin/bin/love-11.5-x86_64.AppImage -o./build/bin/PLUSKAIZO-Linux-x86_64
cat ./build/bin/PLUSKAIZO-Linux-x86_64/bin/love ./PLUSKAIZO.love > ./build/bin/PLUSKAIZO-Linux-x86_64/bin/PLUSKAIZO
chmod +x ./build/bin/PLUSKAIZO-Linux-x86_64/bin/PLUSKAIZO

rm ./build/bin/PLUSKAIZO-Linux-x86_64/bin/love
rm ./build/bin/PLUSKAIZO-Linux-x86_64/AppRun
rm ./build/bin/PLUSKAIZO-Linux-x86_64/love.desktop
rm ./build/bin/PLUSKAIZO-Linux-x86_64/love.svg

cp ./love-bin/run_PLUSKAIZO_linux.sh ./build/bin/PLUSKAIZO-Linux-x86_64/run_PLUSKAIZO_linux.sh

#zip everything

cd ./build/bin/

zip -r ../PLUSKAIZO_macOS.zip ./PLUSKAIZO.app
zip -r ../PLUSKAIZO_Win32.zip ./PLUSKAIZO-Win32
zip -r ../PLUSKAIZO_Linux_x86_64.zip ./PLUSKAIZO-Linux-x86_64
cd ../
rm -r ./bin

