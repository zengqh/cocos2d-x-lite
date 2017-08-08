DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Build all static libraries.
xcodebuild -workspace cocos2d_prebuilt.xcworkspace -scheme Pods-common-libcocos2d_prebuilt_desktop -configuration Debug   -sdk macosx          ONLY_ACTIVE_ARCH=NO -arch x86_64                         BUILD_DIR=$DIR/Products
xcodebuild -workspace cocos2d_prebuilt.xcworkspace -scheme Pods-common-libcocos2d_prebuilt_desktop -configuration Release -sdk macosx          ONLY_ACTIVE_ARCH=NO -arch x86_64                         BUILD_DIR=$DIR/Products
xcodebuild -workspace cocos2d_prebuilt.xcworkspace -scheme Pods-common-libcocos2d_prebuilt_mobile  -configuration Debug   -sdk iphoneos        ONLY_ACTIVE_ARCH=NO -arch armv7 -arch armv7s -arch arm64 BUILD_DIR=$DIR/Products
xcodebuild -workspace cocos2d_prebuilt.xcworkspace -scheme Pods-common-libcocos2d_prebuilt_mobile  -configuration Release -sdk iphoneos        ONLY_ACTIVE_ARCH=NO -arch armv7 -arch armv7s -arch arm64 BUILD_DIR=$DIR/Products
xcodebuild -workspace cocos2d_prebuilt.xcworkspace -scheme Pods-common-libcocos2d_prebuilt_mobile  -configuration Debug   -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO -arch x86_64                         BUILD_DIR=$DIR/Products
xcodebuild -workspace cocos2d_prebuilt.xcworkspace -scheme Pods-common-libcocos2d_prebuilt_mobile  -configuration Release -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO -arch x86_64                         BUILD_DIR=$DIR/Products

# $1 = source file
# $2 = destination file
function compress() {
    # Compress using 7z:
    # 7z -mmt -bb3 -mx=9 -mfb=273 a libcocos2d-x-debug.7z libcocos2d-x-debug.a
    echo ==== Compress: $1 to $2 ====
    7z -mmt -bb3 -mx=9 -mfb=273 a $2 $1
}

# Create fat library.
# https://stackoverflow.com/questions/2996235/how-to-build-a-library-for-both-iphone-simulator-and-device
function combine() {
    echo ==== Combine: $1 and $2 to $3 ====
    lipo -create $1 $2 -output $3
}

# Unique ID generated by Pod.
OSX_LIBS_ID=f4dd317c
IOS_LIBS_ID=8b8cc858

OSX_DEBUG_PREBUILT_LIBS_DIR=$DIR/Products/Debug/cocos2d-x-$OSX_LIBS_ID/libcocos2d-x-$OSX_LIBS_ID.a
OSX_RELEASE_PREBUILT_LIBS_DIR=$DIR/Products/Release/cocos2d-x-$OSX_LIBS_ID/libcocos2d-x-$OSX_LIBS_ID.a

IOS_DEBUG_PREBUILT_LIBS_DIR=$DIR/Products/Debug-iphoneos/cocos2d-x-$IOS_LIBS_ID/libcocos2d-x-$IOS_LIBS_ID.a
IOS_RELEASE_PREBUILT_LIBS_DIR=$DIR/Products/Release-iphoneos/cocos2d-x-$IOS_LIBS_ID/libcocos2d-x-$IOS_LIBS_ID.a

SIM_DEBUG_PREBUILT_LIBS_DIR=$DIR/Products/Debug-iphonesimulator/cocos2d-x-$IOS_LIBS_ID/libcocos2d-x-$IOS_LIBS_ID.a
SIM_RELEASE_PREBUILT_LIBS_DIR=$DIR/Products/Release-iphonesimulator/cocos2d-x-$IOS_LIBS_ID/libcocos2d-x-$IOS_LIBS_ID.a

# Create fat libraries for Iphone.
IOS_COMPRESSED_LIBS_DIR=$DIR/../libs/ios
mkdir -p $IOS_COMPRESSED_LIBS_DIR

IOS_DEBUG_FAT_LIBS_DIR=$IOS_COMPRESSED_LIBS_DIR/libcocos2d-x-debug.a
IOS_RELEASE_FAT_LIBS_DIR=$IOS_COMPRESSED_LIBS_DIR/libcocos2d-x-release.a

combine $IOS_DEBUG_PREBUILT_LIBS_DIR $SIM_DEBUG_PREBUILT_LIBS_DIR $IOS_DEBUG_FAT_LIBS_DIR
combine $IOS_RELEASE_PREBUILT_LIBS_DIR $SIM_RELEASE_PREBUILT_LIBS_DIR $IOS_RELEASE_FAT_LIBS_DIR

# Compress libraries for iOS.
compress $IOS_DEBUG_FAT_LIBS_DIR $IOS_COMPRESSED_LIBS_DIR/libcocos2d-x-debug.7z
compress $IOS_RELEASE_FAT_LIBS_DIR $IOS_COMPRESSED_LIBS_DIR/libcocos2d-x-release.7z

# Compress libraries for Mac OSX.
MAC_COMPRESSED_LIBS_DIR=$DIR/../libs/mac
mkdir -p $MAC_COMPRESSED_LIBS_DIR

MAC_DEBUG_FAT_LIBS_DIR=$MAC_COMPRESSED_LIBS_DIR/libcocos2d-x-debug.a
MAC_RELEASE_FAT_LIBS_DIR=$MAC_COMPRESSED_LIBS_DIR/libcocos2d-x-release.a

cp $OSX_DEBUG_PREBUILT_LIBS_DIR $MAC_DEBUG_FAT_LIBS_DIR
cp $OSX_RELEASE_PREBUILT_LIBS_DIR $MAC_RELEASE_FAT_LIBS_DIR

compress $MAC_DEBUG_FAT_LIBS_DIR $MAC_COMPRESSED_LIBS_DIR/libcocos2d-x-debug.7z
compress $MAC_RELEASE_FAT_LIBS_DIR $MAC_COMPRESSED_LIBS_DIR/libcocos2d-x-release.7z