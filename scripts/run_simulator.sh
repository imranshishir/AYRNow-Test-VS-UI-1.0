#!/usr/bin/env bash
# Build for iOS Simulator and run AYRNOW.
# Usage: ./scripts/run_simulator.sh   (from project root)
# Ensure a simulator is booted: Xcode → Open Developer Tool → Simulator

set -e
cd "$(dirname "$0")/.."

echo "Building for iOS Simulator..."
flutter build ios --simulator --no-codesign

echo "Running on iOS Simulator..."
# Always use iPhone 17 Pro
flutter run -d "iPhone 17 Pro"
