#!/bin/sh
set -eu

version=${SALAM_VERSION:?}
ref=${SALAM_STD_REF:-}
work=${1:?usage: setup-salam.sh <folder> <platform>}
platform=${2:?usage: setup-salam.sh <folder> <platform>}
name="salam-$version-$platform.tar.gz"

mkdir -p "$work/compiler"
cd "$work"
gh release download "v$version" --repo SalamLang/Salam --clobber \
    -p "$name" -p "$name.sha256"
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum -c "$name.sha256"
else
    shasum -a 256 -c "$name.sha256"
fi
tar -xzf "$name" -C compiler
salam=$(find "$work/compiler" -type f -name salam | head -n 1)
[ -n "$salam" ] || { echo "No salam program in $name" >&2; exit 1; }
chmod +x "$salam"
echo "SALAM=$salam" >>"$GITHUB_ENV"

if [ -n "$ref" ]; then
    git init -q source
    git -C source remote add origin https://github.com/SalamLang/Salam.git
    git -C source sparse-checkout set std
    git -C source fetch -q --depth 1 --filter=blob:none origin "$ref"
    git -C source checkout -q FETCH_HEAD
    echo "SALAM_STD=$work/source/std" >>"$GITHUB_ENV"
fi
