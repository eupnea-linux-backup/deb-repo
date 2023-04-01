#!/bin/bash
# This script will pack eupnea-utils into a debian package
set -e

# create dirs
mkdir -p eupnea-utils/DEBIAN
mkdir -p eupnea-utils/usr/bin
mkdir -p eupnea-utils/usr/lib/eupnea
mkdir -p eupnea-utils/etc/eupnea
mkdir -p eupnea-utils/etc/systemd/system/

# Clone postinstall + audio repo
git clone --depth=1 https://github.com/eupnea-linux/eupnea-utils.git remote-eupnea-utils
git clone --depth=1 https://github.com/eupnea-linux/audio-scripts.git

# Copy scripts into package
install -Dm 755 remote-eupnea-utils/user-scripts/* eupnea-utils/usr/bin
install -Dm 755 audio-scripts/setup-audio eupnea-utils/usr/bin

# Copy systemd services into package
cp remote-eupnea-utils/systemd-services/* eupnea-utils/etc/systemd/system

# Copy libs into package
cp remote-eupnea-utils/system-scripts/* eupnea-utils/usr/lib/eupnea
cp remote-eupnea-utils/functions.py eupnea-utils/usr/lib/eupnea

# Copy configs into package
cp -r audio-scripts/configs/* eupnea-utils/etc/eupnea

# copy debian control files into package
cp control-files/utils-control eupnea-utils/DEBIAN/control
# Add postinst script to package
install -Dm 755 postinst-scripts/utils-postinst eupnea-utils/DEBIAN/postinst

# create package
# by default dpkg-deb will use zstd compression. The deploy action will fail because the debian tool doesnt support zstd compression in packages.
dpkg-deb --build --root-owner-group -Z=xz eupnea-utils
