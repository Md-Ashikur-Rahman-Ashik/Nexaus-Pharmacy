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

# Set Android SDK Environment Variables
echo 'export ANDROID_SDK_ROOT=/usr/local/lib/android/sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools' >> ~/.bashrc
export ANDROID_SDK_ROOT=/usr/local/lib/android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# 2. Install required SDK packages (API 35, Build Tools)
echo "📦 [INFRA] Installing Android API 35 & Build Tools..."
yes | sdkmanager --licenses > /dev/null 2>&1
sdkmanager "platforms;android-35" "build-tools;35.0.0" "platform-tools" > /dev/null

# 3. Install Flutter via Git (The Bulletproof Method)
echo "🐦 [INFRA] Installing latest Flutter Stable via Git..."
cd /opt
# Cloning the stable branch directly from the official repo
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add Flutter to PATH for the script
export PATH=$PATH:/opt/flutter/bin
# Add Flutter to PATH for future terminal sessions
echo 'export PATH=$PATH:/opt/flutter/bin' >> ~/.bashrc

# 4. Run Flutter Doctor and Precache Artifacts
echo "🩺 [INFRA] Running Flutter Doctor..."
flutter doctor -v
flutter precache --android

echo "✅ [INFRA] Environment setup complete."