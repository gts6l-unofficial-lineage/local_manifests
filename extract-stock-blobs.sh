#!/usr/bin/env bash
#
# SPDX-License-Identifier: Apache-2.0
#
# Fetch the stock firmware for the Galaxy Tab S6 LTE (SM-T865) from Samsung's
# update servers, unpack its vendor image and run the LineageOS extraction
# scripts on it. Nothing is redistributed: the files go straight from Samsung
# into vendor/samsung/ of your source tree.
#
# Usage:  extract-stock-blobs.sh <lineage source tree> [firmware.zip]
#
#   firmware.zip   an already downloaded SM-T865 firmware package; skips the
#                  download (about 6 GB)
#
# Environment:
#   REGION   CSC region to download for (default DBT)
#   WORKDIR  where to download and unpack (default ./gts6l-firmware, ~12 GB)
#
# Needs: samloader (samloader-rs), unzip, tar, lz4, simg2img, debugfs
# (e2fsprogs), python3.

set -euo pipefail

MODEL=SM-T865
EXPECTED=T865XXU6DXE1          # vendor build the proprietary file lists were made from
REGION=${REGION:-DBT}
WORKDIR=${WORKDIR:-$PWD/gts6l-firmware}

die() { echo "error: $*" >&2; exit 1; }

[ $# -ge 1 ] || die "usage: $0 <lineage source tree> [firmware.zip]"
TREE=$(realpath "$1")
ZIP=${2:-}
DEVICE_DIR=$TREE/device/samsung/gts6l
[ -x "$DEVICE_DIR/extract-files.py" ] || die "$DEVICE_DIR/extract-files.py not found; run 'repo sync' first"

need="unzip tar lz4 simg2img debugfs python3"
[ -n "$ZIP" ] || need="samloader $need"
for tool in $need; do
    command -v "$tool" >/dev/null || die "'$tool' is not installed"
done

mkdir -p "$WORKDIR"
cd "$WORKDIR"

if [ -z "$ZIP" ]; then
    echo ">> Downloading the latest $MODEL firmware for region $REGION from Samsung"
    mkdir -p download
    samloader download --model "$MODEL" --region "$REGION" --out-dir download
    ZIP=$(ls -t download/*.zip | head -n 1)
fi
ZIP=$(realpath "$ZIP")
[ -f "$ZIP" ] || die "firmware package $ZIP not found"

echo ">> Unpacking the vendor image from $(basename "$ZIP")"
AP=$(unzip -Z1 "$ZIP" | grep -E '^AP_.*\.tar\.md5$' | head -n 1)
[ -n "$AP" ] || die "no AP_*.tar.md5 in $ZIP"
rm -rf vendor.img.ext4.lz4 vendor.sparse.img vendor.img dump
# tar stops with an error at the md5 trailer of the archive; the member is complete by then
unzip -p "$ZIP" "$AP" | tar -xf - vendor.img.ext4.lz4 2>/dev/null || true
[ -s vendor.img.ext4.lz4 ] || die "vendor.img.ext4.lz4 not found in $AP"
lz4 -d -q vendor.img.ext4.lz4 vendor.sparse.img
simg2img vendor.sparse.img vendor.img
rm -f vendor.img.ext4.lz4 vendor.sparse.img

mkdir -p dump/vendor
# debugfs reads the ext4 image without root; it cannot set owners, which is harmless here
debugfs -R "rdump / dump/vendor" vendor.img >/dev/null 2>&1 || true
[ -f dump/vendor/build.prop ] || die "could not unpack the vendor image"
rm -f vendor.img

FOUND=$(sed -n 's/^ro\.vendor\.build\.version\.incremental=//p' dump/vendor/build.prop)
echo ">> Vendor build: $FOUND"
if [ "$FOUND" != "$EXPECTED" ]; then
    echo "warning: the file lists were made from $EXPECTED; files may be missing or differ" >&2
fi

echo ">> Extracting the proprietary files into $TREE/vendor/samsung"
cd "$DEVICE_DIR"
./extract-files.py "$WORKDIR/dump"

echo ">> Done. The unpacked firmware is in $WORKDIR/dump and can be deleted."
