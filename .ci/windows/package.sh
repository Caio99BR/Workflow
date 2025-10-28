#!/bin/bash

# SPDX-FileCopyrightText: Copyright 2025 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

ROOTDIR="$PWD"
BUILDDIR="$ROOTDIR/${BUILDDIR:-build}"
WINDEPLOYQT="${WINDEPLOYQT:-windeployqt}"

set +e
rm -f "$BUILDDIR/bin/"*.pdb
set -e

"$WINDEPLOYQT" \
    --release \
    --no-compiler-runtime \
    --no-opengl-sw \
    --no-system-dxc-compiler \
    --no-system-d3d-compiler \
    --dir "$BUILDDIR/pkg" \
    "$BUILDDIR/bin/eden.exe"
cp "$BUILDDIR/bin/"* "$BUILDDIR/pkg/"

GITDATE=$(git show -s --date=short --format='%ad' | tr -d "-")
GITREV=$(git show -s --format='%h')

ZIP_NAME="Eden-Windows-${ARCH}-${GITDATE}-${GITREV}.zip"

ARTIFACTS_DIR="$ROOTDIR/artifacts"
PKG_DIR="$BUILDDIR/pkg"

mkdir -p "$ARTIFACTS_DIR"

TMP_DIR=$(mktemp -d)

cp -r "$PKG_DIR"/* "$TMP_DIR"/
cp -r "$ROOTDIR/LICENSE"* "$TMP_DIR"/
cp -r "$ROOTDIR/README"* "$TMP_DIR"/

7z a -tzip "$ARTIFACTS_DIR/$ZIP_NAME" "$TMP_DIR"/*

rm -rf "$TMP_DIR"

echo "Windows package created at $ARTIFACTS_DIR/$ZIP_NAME"
