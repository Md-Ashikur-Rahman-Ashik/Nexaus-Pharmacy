#!/bin/bash
set -e

echo "🚀 [INFRA] Starting environment provisioning..."

# 1. Install Android SDK Command Line Tools
echo "📦 [INFRA] Installing Android SDK..."
mkdir -p /usr/local/lib/android/sdk
cd /usr/local/lib/android/sdk
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdtools.zip
unzip -q cmdtools.zip
rm cmdtools.zip
mv cmdline-tools latest

# Set Android SDK Environment Variables (Persisted for the workspace)
echo 'export ANDROID_SDK_ROOT=/usr/local/lib/android/sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools' >> ~/.bashrc
source ~/.bashrc

# 2. Install required SDK packages (API 35, Build Tools, Platform Tools)
echo "📦 [INFRA] Installing Android API 35 & Build Tools..."
yes | sdkmanager --licenses > /dev/null 2>&1
sdkmanager "platforms;android-35" "build-tools;35.0.0" "platform-tools" > /dev/null

# 3. Install Flutter 4.x Stable
echo "🐦 [INFRA] Installing Flutter 4.x..."
cd /opt
wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_4.0.0-stable.tar.xz -O flutter.tar.xz
tar xf flutter.tar.xz
rm flutter.tar.xz

# Add Flutter to PATH
echo 'export PATH=$PATH:/opt/flutter/bin' >> ~/.bashrc
source ~/.bashrc

# 4. Run Flutter Doctor and Precache Artifacts
echo "🩺 [INFRA] Running Flutter Doctor..."
flutter doctor -v
flutter precache --android

echo "✅ [INFRA] Environment setup complete. Flutter $(flutter --version | head -n 1) is ready."
