#!/bin/bash

set -e

TOOLCHAIN_DIR="${TOOLCHAIN_DIR:-"/opt/arm-webos-linux-gnueabi_sdk-buildroot"}"
SYSROOT="$TOOLCHAIN_DIR/arm-webos-linux-gnueabi/sysroot"
READELF="$TOOLCHAIN_DIR/bin/arm-webos-linux-gnueabi-readelf"

# Copy a library from the toolchain sysroot into dist/, named after its SONAME,
# so the package does not depend on the exact library versions the toolchain ships.
copy_lib() {
	local lib="$1"
	local soname
	soname=$("$READELF" -d "$lib" | sed -n 's/.*(SONAME).*\[\(.*\)\]/\1/p')
	if [ -z "$soname" ]; then
		echo "Could not determine SONAME of $lib" >&2
		exit 1
	fi
	cp -L "$lib" "dist/$soname"
}

rm -rf dist/
mkdir dist/
cp -r ../../build/ai dist/ai
cp -r ../../build/baseset dist/baseset
cp -r ../../build/game dist/game
cp -r ../../build/lang dist/lang
cp -r ../../build/openttd dist/openttd
cp -r public/. dist/

mkdir -p dist/lib
copy_lib "$SYSROOT/usr/lib/libicudata.so"
copy_lib "$SYSROOT/usr/lib/libicui18n.so"
copy_lib "$SYSROOT/usr/lib/libicuuc.so"
copy_lib "$SYSROOT/usr/lib/libstdc++.so"
copy_lib "$SYSROOT/usr/lib/libfluidsynth.so"
copy_lib "$SYSROOT/usr/lib/libreadline.so"
copy_lib "$SYSROOT/lib/libatomic.so"

ares-package dist/
