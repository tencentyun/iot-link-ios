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
  login tonychanchen@gmail.com
  password a85347ed36518bffb15c2cd11ad1dc95
EOF

pod spec lint TIoTLinkKit.podspec --allow-warnings --verbose
