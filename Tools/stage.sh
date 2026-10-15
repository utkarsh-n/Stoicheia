#!/bin/zsh
set -euo pipefail
source_root="${0:A:h:h}"
stage_root="${STOICHEIA_STAGE:-/private/tmp/stoicheia-build}"
mkdir -p "$stage_root/Stoicheia" "$stage_root/LabKit"
rsync -a --delete --exclude .build --exclude .git --exclude '*.xcodeproj' --exclude Documentation/QA "$source_root/" "$stage_root/Stoicheia/"
rsync -a --delete --exclude .build --exclude .git --exclude '*.xcodeproj' "$source_root/../LabKit/" "$stage_root/LabKit/"
cd "$stage_root/Stoicheia"
xcodegen generate
echo "$stage_root/Stoicheia/Stoicheia.xcodeproj"
