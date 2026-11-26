#!/bin/sh
set -eu

here=$(cd "$(dirname "$0")" && pwd)
salam=${SALAM:-salam}
std=${SALAM_STD:-}
version=${VERSION:-1.0.0}
case $(uname -s) in
Darwin) host=macos ;;
Linux) host=linux ;;
*) host=windows ;;
esac
platform=${1:-$host}

compile() {
    if [ -n "$std" ]; then
        "$salam" build "$@" --stdlib-path="$std"
    else
        "$salam" build "$@"
    fi
}

relays() {
    for arch in x86_64 aarch64; do
        if [ -n "${SALAM_RELAYS:-}" ]; then
            cp "$SALAM_RELAYS/salam-udprelay-linux-$arch" "$1/"
            chmod 755 "$1/salam-udprelay-linux-$arch"
            continue
        fi
        musl=${SALAM_SYSROOTS:-$HOME/.salam/sysroots}/$arch-linux-musl
        out="$1/salam-udprelay-linux-$arch"
        if [ -f "$musl/libc.a" ]; then
            (
                export SALAM_MUSL_SYSROOT="$musl"
                compile "$here/relay/main.salam" \
                    --target="$arch-linux-musl" --backend=native --linker=builtin -o "$out"
            )
        elif ! compile "$here/relay/main.salam" --target="$arch-linux-musl" \
            --backend=native --linker=builtin -o "$out"; then
            echo "No musl toolchain for $arch: UDP will not work with such servers" >&2
        fi
    done
}

wintun() {
    version=0.14.1
    sum=07c256185d6ee3652e09fa55c0b673e2624b565e02c4b9091c79ca7d2f24ef51
    work=$(mktemp -d)
    curl -fsSL -A salam-build -o "$work/wintun.zip" \
        "https://www.wintun.net/builds/wintun-$version.zip"
    if command -v sha256sum >/dev/null 2>&1; then
        got=$(sha256sum "$work/wintun.zip" | cut -d' ' -f1)
    else
        got=$(shasum -a 256 "$work/wintun.zip" | cut -d' ' -f1)
    fi
    if [ "$got" != "$sum" ]; then
        echo "The wintun download does not match its checksum" >&2
        exit 1
    fi
    unzip -p "$work/wintun.zip" wintun/bin/amd64/wintun.dll >"$1/wintun.dll"
    unzip -p "$work/wintun.zip" wintun/LICENSE.txt >"$1/wintun-LICENSE.txt"
    rm -r "${work:?}"
}

case $platform in
relays)
    dir="${2:-$here/dist/relays}"
    mkdir -p "$dir"
    relays "$dir"
    echo "Built the relays in $dir"
    ;;
macos)
    app="${2:-$HOME/Applications}/Salam Tunnel.app"
    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
    compile "$here" --ui=native -o "$app/Contents/MacOS/salam-tunnel"
    relays "$app/Contents/Resources"
    cat > "$app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>salam-tunnel</string>
    <key>CFBundleIdentifier</key>
    <string>ir.salamlang.sshtunnel</string>
    <key>CFBundleName</key>
    <string>Salam Tunnel</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$version</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST
    codesign --force --sign - "$app" >/dev/null 2>&1 || true
    echo "Built $app"
    ;;
linux)
    dir="${2:-$here/dist/linux}"
    mkdir -p "$dir"
    compile "$here" --ui=native --backend=native --linker=system -o "$dir/salam-tunnel"
    relays "$dir"
    echo "Built $dir/salam-tunnel"
    ;;
windows)
    dir="${2:-$here/dist/windows}"
    mkdir -p "$dir"
    compile "$here" --ui=native --target=x86_64-w64-windows-gnu --backend=native \
        --subsystem=windows -o "$dir/salam-tunnel.exe"
    relays "$dir"
    wintun "$dir"
    echo "Built $dir/salam-tunnel.exe"
    ;;
*)
    echo "usage: build.sh [macos|linux|windows|relays] [folder]" >&2
    exit 2
    ;;
esac
