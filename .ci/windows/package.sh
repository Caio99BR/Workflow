#!/bin/sh -e

# SPDX-FileCopyrightText: Copyright 2025 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC1091
. .ci/common/platform.sh

BUILDDIR="${BUILDDIR:-build}"
WINDEPLOYQT="${WINDEPLOYQT:-windeployqt6}"

set +e
rm -f "${BUILDDIR}/bin/"*.pdb
set -e

"${WINDEPLOYQT}" --release --no-compiler-runtime --no-opengl-sw --no-system-dxc-compiler --no-system-d3d-compiler --dir "${BUILDDIR}/pkg" "${BUILDDIR}/bin/eden.exe"
cp "${BUILDDIR}/bin/"* "${BUILDDIR}/pkg"

if [ "$PLATFORM" = "msys" ]; then
    echo "-- On MSYS, bundling MinGW DLLs..."
    ldd "${BUILDDIR}/pkg/eden.exe" \
        | grep -iv system32 \
        | grep -vi windows \
        | grep -v :$ \
        | cut -f2 -d\> \
        | cut -f1 -d\( \
        | tr '\\' '/' \
        | while read a; do
            dst="${BUILDDIR}/pkg/$(basename "$a")"
            if [ ! -e "$dst" ]; then
                cp -v "$a" "$dst"
            fi
        done
fi

GITDATE=$(git show -s --date=short --format='%ad' | tr -d "-")
GITREV=$(git show -s --format='%h')

ZIP_NAME="Eden-Windows-${ARCH}-${GITDATE}-${GITREV}.zip"

ARTIFACTS_DIR="artifacts"
PKG_DIR="${BUILDDIR}/pkg"

mkdir -p "$ARTIFACTS_DIR"

TMP_DIR=$(mktemp -d)

cp -r "$PKG_DIR"/* "$TMP_DIR"/
cp -r LICENSE* README* "$TMP_DIR"/

7z a -tzip "$ARTIFACTS_DIR/$ZIP_NAME" "$TMP_DIR"/*

rm -rf "$TMP_DIR"
