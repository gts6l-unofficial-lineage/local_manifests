# SPDX-FileCopyrightText: 2026 lunar-seal
# SPDX-License-Identifier: Apache-2.0
#
# AOSP/LineageOS build env on NixOS: `nix-build .repo/local_manifests/nix/fhs.nix -o fhs` then `./fhs/bin/lineage-build` (or `-c "cmd"`).
# AOSP ships its own clang, JDK and build tools in prebuilts/; this only provides what it expects from the host.
{ pkgs ? import <nixpkgs> { } }:
pkgs.buildFHSEnv {
  name = "lineage-build";
  targetPkgs = p: with p; [
    bc bison ccache curl flex git git-lfs gitRepo gnumake gnupg gperf
    libxml2 lz4 m4 ncurses5 openssl perl procps python3 rsync schedtool
    util-linux which xz zip unzip zlib zstd freetype fontconfig
    openssh cpio kmod e2fsprogs android-tools
    # headers for the 4.14 kernel host tools (Lineage passes HOSTCFLAGS=-I/usr/include for non-NO_GCC kernels)
    glibc.dev openssl.dev zlib.dev
    # crtbegin.o/libgcc under /usr/lib/gcc/<triple>/<ver> for clang host links (Ubuntu-style GCC install)
    gcc-unwrapped gcc-unwrapped.lib
    libxcrypt-legacy   # libcrypt.so.1 for prebuilts/tools-lineage perl
  ];
  multiPkgs = p: with p; [ zlib ncurses5 ];
  profile = ''
    export ALLOW_NINJA_ENV=true
    export CCACHE_EXEC=${pkgs.ccache}/bin/ccache   # set USE_CCACHE=1 and CCACHE_DIR to use it
    export LC_ALL=C.UTF-8
  '';
  runScript = "bash";
}
