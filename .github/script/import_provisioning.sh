#!/bin/sh

# Decrypt the files
# --batch to prevent interactive command --yes to assume "yes" for questions
#gpg --quiet --batch --yes --decrypt --passphrase="$PROVISIONING_PASSWORD" --output .github/script/apple_dev.p12 .github/script/opensource_keystore.p12.asc
#gpg --quiet --batch --yes --decrypt --passphrase="$PROVISIONING_PASSWORD" --output .github/script/dev.mobileprovision .github/script/opensource_keystore.mobileprovision.asc

if [ $1 == 'Debug' ]; then
    echo "Debug"
    gpg -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/opensource.p12.asc > .github/script/apple_dev.p12
    gpg -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/opensource.mobileprovision.asc > .github/script/dev.mobileprovision
else
    echo "Release"
    gpg -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/tencent_official.p12.asc > .github/script/apple_dev.p12
    gpg -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/tencent_official.mobileprovision.asc > .github/script/dev.mobileprovision
    gpg -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/LinkApp.xcconfig.asc > .github/script/dev.mobileprovision
    gpg -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/app-config.json.asc > LinkApp/Supporting\ Files/app-config.json
    gpg -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/LinkApp.xcconfig.asc > LinkApp/Supporting\ Files/LinkApp.xcconfig
    gpg -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/GoogleService-Info.plist.asc > LinkApp/Supporting\ Files/GoogleService-Info.plist
fi



mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

echo "List profiles"
ls ~/Library/MobileDevice/Provisioning\ Profiles/
echo "Move profiles"
cp .github/script/*.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
echo "List profiles"
ls ~/Library/MobileDevice/Provisioning\ Profiles/

security create-keychain -p "" build.keychain
security import .github/script/apple_dev.p12 -t agg -k ~/Library/Keychains/build.keychain -P "$P12_EXPORT_CCHARLESREN_PASSWORD" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
