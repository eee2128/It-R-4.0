#!/bin/bash
# Script to automate Firebase Emulator Suite and iOS app testing

set -e

# Start Firebase emulators in the background
cd "$(dirname "$0")/functions"
echo "Starting Firebase emulators..."
npm run emulators &
EMULATOR_PID=$!
cd ..

# Wait for emulators to be ready
sleep 5

# Build and run the iOS app in the simulator (Debug mode)
echo "Building and launching the iOS app in Simulator..."
open -a Simulator
xcodebuild -project "MIDI Studio.xcodeproj" -scheme "MIDI Studio" -destination 'platform=iOS Simulator,name=iPhone 15' build

# Wait for user to finish testing
read -p "Press [Enter] to stop emulators and exit..."

# Stop emulators
kill $EMULATOR_PID
