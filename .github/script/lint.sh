#!/bin/sh

#bin/bsah - l

# Configure hub to use https instead of the git protocol
git config --global hub.protocol https

# Configure the hub user
mkdir ~/.config
cat >>~/.config/hub <<EOF
github.com:
- user: $GITHUB_ACTOR
EOF

# Set the default basic-auth credentials for gits http access
rm ~/.netrc
touch ~/.netrc
cat >>~/.netrc <<EOF
machine github.com
  login $GITHUB_ACTOR
  password $GITHUB_TOKEN
  
machine trunk.cocoapods.org
  login $COCOAPODS_TRUNK_ACTOR
  password $COCOAPODS_TRUNK_TOKEN
EOF

pod spec lint TIoTLinkKit.podspec --allow-warnings --verbose
