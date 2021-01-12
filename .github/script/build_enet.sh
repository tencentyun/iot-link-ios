#!/bin/sh

gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/CMakeLists.txt.asc > .github/script/CMakeLists.txt

# 1.拉取eNet支持库
git clone https://$GIT_ACCESS_TOKEN@github.com/tencentyun/iot-p2p.git

cd iot-p2p/components_src/eNet



# 2.编译iOS平台工程配置
mkdir -p build/ios

cd build/ios

#TODO makefile需加密
cp ../../../../../.github/script/CMakeLists.txt   ../../CMakeLists.txt
cp ../../../../app/app_p2p.h   ../../../../app/src/app_p2p.h
cp ../../../qcloud-iot-explorer-sdk-embedded-c/include/config.h   ../../../../app/src/config.h
cp ../../../qcloud-iot-explorer-sdk-embedded-c/include/lite-list.h   ../../../../app/src/lite-list.h
cp ../../../qcloud-iot-explorer-sdk-embedded-c/include/lite-utils.h   ../../../../app/src/lite-utils.h
cp ../../../qcloud-iot-explorer-sdk-embedded-c/include/platform.h   ../../../../app/src/platform.h
cp ../../../qcloud-iot-explorer-sdk-embedded-c/include/qcloud_iot_import.h   ../../../../app/src/qcloud_iot_import.h

# mv config.h  lite-list.h  lite-utils.h  platform.h  qcloud_iot_import.h

mv ../../../../app/ ../../../../components_src/eNet/extension/
cmake ../.. -GXcode -DCMAKE_INSTALL_PREFIX=$PWD/INSTALL -DENET_SELF_SIGN=ON -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_BUILD_TYPE=Debug -DENET_VERSION=v1.0.0 -DPYTHON_EXECUTABLE:FILEPATH=/usr/bin/python3



# build lib
#rm -rf build
xcodebuild build -project eNet.xcodeproj -scheme enet_static -configuration Release -sdk iphoneos -derivedDataPath ./build
#xcodebuild build -project eNet.xcodeproj -scheme enet_static -configuration Release -sdk iphonesimulator -derivedDataPath ./build

#strip -x -S Release-iphoneos/libenet.a -o  Release-iphoneos/libenet_.a
#lipo -info Release-iphoneos/libenet.a
