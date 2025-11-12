#!/bin/bash

# allow specifying different destination directory
DIR="${DIR:-"$HOME/.local/bin"}"

# map different architecture variations to the available binaries
ARCH=$(uname -m)
case $ARCH in
    i386|i686) ARCH=x86 ;;
    armv6*) ARCH=armv6 ;;
    armv7*) ARCH=armv7 ;;
    aarch64*) ARCH=arm64 ;;
esac

# prepare the download URL
GITHUB_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/jesseduffield/lazydocker/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
GITHUB_FILE="lazydocker_${GITHUB_LATEST_VERSION//v/}_$(uname -s)_${ARCH}.tar.gz"
GITHUB_URL="https://github.com/jesseduffield/lazydocker/releases/download/${GITHUB_LATEST_VERSION}/${GITHUB_FILE}"

# install/update the local binary
curl -L -o lazydocker.tar.gz $GITHUB_URL
tar xzf lazydocker.tar.gz
# Find the extracted directory (it will be the only lazydocker_* directory)
ARCHIVE_DIR=$(find . -maxdepth 1 -type d -name "lazydocker_*" | head -1)
if [ -n "$ARCHIVE_DIR" ] && [ -f "$ARCHIVE_DIR/lazydocker" ]; then
	install -Dm 755 "$ARCHIVE_DIR/lazydocker" -t "$DIR"
	rm -rf "$ARCHIVE_DIR" lazydocker.tar.gz
else
	echo "Error: Could not find lazydocker binary in archive"
	rm -f lazydocker.tar.gz
	exit 1
fi
