## Download

| Your computer             | File                                       |
| ------------------------- | ------------------------------------------ |
| Mac with Apple silicon    | `SalamTunnel-@VERSION@-macos-arm64.dmg`    |
| Mac with an Intel chip    | `SalamTunnel-@VERSION@-macos-x86_64.dmg`   |
| Windows, 64-bit           | `SalamTunnel-@VERSION@-windows-x86_64.zip` |
| Linux on x86_64           | `SalamTunnel-@VERSION@-linux-x86_64.tar.gz`  |
| Linux on arm64            | `SalamTunnel-@VERSION@-linux-aarch64.tar.gz` |

Nothing needs to be compiled. `SHA256SUMS` lists the checksum of every file.

## macOS

Open the disk image and drag **Salam Tunnel** to **Applications**. The app is
not notarized by Apple, so macOS blocks it the first time. Open it once, then go
to **System Settings > Privacy & Security** and press **Open Anyway**. Or run:

```sh
xattr -dr com.apple.quarantine "/Applications/Salam Tunnel.app"
```

## Windows

Unzip the whole folder and run `salam-tunnel.exe` from inside it; keep the other
files next to it. The program is not signed, so if SmartScreen appears, press
**More info** and **Run anyway**. Password sign-in needs
[OpenSSH 8.4 or newer](https://github.com/PowerShell/Win32-OpenSSH/releases).

## Linux

```sh
tar -xzf SalamTunnel-@VERSION@-linux-x86_64.tar.gz
./salam-tunnel/salam-tunnel
```

It needs `openssh-client`, `iproute2`, `curl`, the X11 library and polkit
(`pkexec`) unless you start it as root.
