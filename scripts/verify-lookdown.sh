#!/bin/bash
# Verifies Desktop/falling is on the look-down branch before building in Xcode.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Directory: $(pwd)"
echo "Branch:    $(git branch --show-current)"
echo "Commit:    $(git rev-parse --short HEAD)"
echo

fail=0

if [[ "$(git branch --show-current)" != "cursor/multi-ledge-depth-field-6151" ]]; then
  echo "FAIL: wrong branch (need cursor/multi-ledge-depth-field-6151)"
  fail=1
else
  echo "OK: branch"
fi

if ! grep -q "LOOK-DOWN ACTIVE" Falling/ContentView.swift; then
  echo "FAIL: ContentView.swift missing LOOK-DOWN ACTIVE banner"
  fail=1
else
  echo "OK: ContentView.swift banner"
fi

if ! grep -q "LOOK-DOWN+SIGNING" Falling/Game/GameScene.swift; then
  echo "FAIL: GameScene.swift missing LOOK-DOWN+SIGNING stamp"
  fail=1
else
  echo "OK: GameScene.swift stamp"
fi

if ! grep -q "depthFieldLedges" Falling/WorldConstants.swift; then
  echo "FAIL: WorldConstants.swift missing depthFieldLedges"
  fail=1
else
  echo "OK: depthFieldLedges"
fi

if grep -q "CODE_SIGNING_ALLOWED = NO" Falling.xcodeproj/project.pbxproj; then
  echo "FAIL: CODE_SIGNING_ALLOWED is still NO"
  fail=1
else
  echo "OK: signing allowed"
fi

if grep -q "secondPlatformCenter" Falling/WorldConstants.swift; then
  echo "FAIL: still has old secondPlatformCenter (stale file)"
  fail=1
else
  echo "OK: old 2-platform constants removed"
fi

echo
if [[ "$fail" -ne 0 ]]; then
  echo "RESULT: NOT READY — Xcode will show the old camera."
  echo "Run:"
  echo "  git fetch origin"
  echo "  git checkout cursor/multi-ledge-depth-field-6151"
  echo "  git reset --hard origin/cursor/multi-ledge-depth-field-6151"
  exit 1
fi

echo "RESULT: READY — open Falling.xcodeproj from THIS folder, Clean Build Folder, Run."
echo "On device you must see: home-screen name 'Falling LD' and green 'LOOK-DOWN ACTIVE' banner."
exit 0
