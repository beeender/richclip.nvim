#!/usr/bin/env bash

set -ex

export VERSION_STR="$1"
export TARGET_DIR="$2"

echoerr() { echo "$@" 1>&2; }

usage() {
    echo "intall.sh <richclip_version> <target_dir>"
}

if [ -z "$VERSION_STR" ]; then
    echoerr "<richclip_version> is missing"
    usage
    exit 1
fi
if [ -z "$TARGET_DIR" ]; then
    echoerr "<target_dir> is missing"
    usage
    exit 1
fi

download() {
    echo "Downloading richclip binary: " "$1"
    unameOut="$(uname -s)"
    case "${unameOut}" in
    Linux*)
        pushd "$TARGET_DIR"
        curl -fsSL \
            "https://github.com/beeender/richclip/releases/download/v${VERSION_STR}/richclip_v${VERSION_STR}_x86_64-unknown-linux-musl.tar.gz" | \
            tar -xz
        popd
        ;;
    Darwin*)
        pushd "$TARGET_DIR"
        curl -fsSL \
            "https://github.com/beeender/richclip/releases/download/v${VERSION_STR}/richclip_v${VERSION_STR}_aarch64-apple-darwin.tar.gz" | \
            tar -xz
        popd
        ;;
    CYGWIN* | MINGW* | MSYS_NT*)
        echoerr "Windows build is not available yet."
        ;;
    *)
        echoerr "Unknown system '$unameOut'"
        ;;
    esac
}

download "$VERSION_STR"
