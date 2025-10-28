#!/bin/sh -x

# SPDX-FileCopyrightText: Copyright 2025 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

ROOTDIR="$PWD"
ARTIFACTS_DIR="${ROOTDIR}/artifacts"

mkdir -p "$ARTIFACTS_DIR"

ARCHES_DEFAULT="amd64"
ARCHES_LINUX="$ARCHES_DEFAULT steamdeck"
[ "$DISABLE_ARM" != "true" ] && ARCHES_LINUX="$ARCHES_LINUX aarch64"

COMPILERS="gcc"
if [ "$DEVEL" = "false" ]; then
	ARCHES_LINUX="$ARCHES_LINUX legacy rog-ally"
	COMPILERS="$COMPILERS clang"
fi

for arch in $ARCHES_LINUX; do
	for compiler in $COMPILERS; do
		ARTIFACT="Eden-Linux-${ID}-${arch}-${compiler}-standard"

		cp "$ROOTDIR/linux-$arch-$compiler-standard"/*.AppImage "$ARTIFACTS_DIR/$ARTIFACT.AppImage"
		if [ "$DEVEL" = "false" ]; then
			cp "$ROOTDIR/linux-$arch-$compiler-standard"/*.AppImage.zsync "$ARTIFACTS_DIR/$ARTIFACT.AppImage.zsync"
		fi
	done

	if [ "$DEVEL" != "true" ]; then
		ARTIFACT="Eden-Linux-${ID}-${arch}-clang-pgo"

		cp "$ROOTDIR/linux-$arch-clang-pgo"/*.AppImage.zsync "$ARTIFACTS_DIR/$ARTIFACT.AppImage.zsync"
		cp "$ROOTDIR/linux-$arch-clang-pgo"/*.AppImage "$ARTIFACTS_DIR/$ARTIFACT.AppImage"
	fi
done

FLAVORS=standard
[ "$DEVEL" = "false" ] && FLAVORS="standard legacy optimized"

for flavor in $FLAVORS; do
	cp "$ROOTDIR/android-$flavor"/*.apk "$ARTIFACTS_DIR/Eden-Android-${ID}-${flavor}.apk"
done

ARCHES_WINDOWS="$ARCHES_DEFAULT"
[ "$DISABLE_ARM" != "true" ] && ARCHES_WINDOWS="$ARCHES_WINDOWS arm64"
for arch in $ARCHES_WINDOWS; do
	for compiler in clang msvc; do
		cp "$ROOTDIR/windows-$arch-${compiler}-standard"/*.zip "$ARTIFACTS_DIR/Eden-Windows-${ID}-${arch}-${compiler}-standard.zip"
	done

	if [ "$DEVEL" != "true" ]; then
		cp "$ROOTDIR/windows-$arch-clang-pgo"/*.zip "$ARTIFACTS_DIR/Eden-Windows-${ID}-${arch}-clang-pgo.zip"
	fi
done

if [ -d "$ROOTDIR/source" ]; then
	cp "$ROOTDIR/source/source.tar.zst" "$ARTIFACTS_DIR/Eden-Source-${ID}.tar.zst"
fi

cp -r "$ROOTDIR/macos"/*.tar.gz "$ARTIFACTS_DIR/Eden-macOS-${ID}.tar.gz"

# TODO
cp -r "$ROOTDIR/freebsd-binary-amd64-clang"/*.tar.zst "$ARTIFACTS_DIR/Eden-FreeBSD-${ID}-amd64-clang.tar.zst"

ARCHES_DEBIAN="$ARCHES_DEFAULT"
[ "$DISABLE_ARM" != "true" ] && ARCHES_DEBIAN="$ARCHES_DEBIAN aarch64"
for arch in $ARCHES_DEBIAN; do
	for ver in "Ubuntu-24.04" "Debian-12" "Debian-13"; do
		pkg_ver=$(echo "$ver" | tr '[:upper:]' '[:lower:]')
		cp "$ROOTDIR/$pkg_ver-$arch"/eden_*.deb "$ARTIFACTS_DIR/Eden-$ver-${ID}-$arch.deb"
	done
done
