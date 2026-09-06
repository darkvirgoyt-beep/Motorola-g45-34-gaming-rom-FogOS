#!/bin/bash
# Script to setup Android Build Environment for Ubuntu 22.04/24.04

set -e

echo "Setting up VirgoX Elite GamingOS Build Environment..."

# Update and upgrade
sudo apt update
sudo apt upgrade -y

# Install standard Android build dependencies
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python3 python3-pip openjdk-17-jdk repo android-sdk-platform-tools wget

# Install payload-dumper-go
echo "Installing payload-dumper-go..."
wget -qO payload-dumper-go.tar.gz https://github.com/ssut/payload-dumper-go/releases/download/1.2.2/payload-dumper-go_1.2.2_linux_amd64.tar.gz
tar -xzf payload-dumper-go.tar.gz
sudo mv payload-dumper-go /usr/local/bin/
rm -f payload-dumper-go.tar.gz payload-dumper-go.exe

# Configure git if not already configured
if [ -z "$(git config --global user.name)" ]; then
    echo "Please set your git user.name:"
    read -r username
    git config --global user.name "$username"
fi

if [ -z "$(git config --global user.email)" ]; then
    echo "Please set your git user.email:"
    read -r email
    git config --global user.email "$email"
fi

echo "Build environment setup complete!"
