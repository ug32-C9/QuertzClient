#!/bin/bash

main() {
    clear
    echo -e "[ Velonix Mac Installer ] Starting installation..."

    echo -e "[*] Downloading jq (JSON parser)..."
    curl -s "https://git.raptor.fun/main/jq-macos-amd64" -o "./jq" || {
        echo "[!] Failed to download jq."
        exit 1
    }
    chmod +x ./jq

    echo -e "[*] Downloading latest Roblox Player..."
    [ -f ./RobloxPlayer.zip ] && rm -f ./RobloxPlayer.zip

    local versionInfo=$(curl -s "https://raw.githubusercontent.com/ug32-C9/VelonixMac/main/version.json")

    local channel=$(echo "$versionInfo" | ./jq -r ".channel")
    local version=$(echo "$versionInfo" | ./jq -r ".\"roblox-client\"")

    curl -s "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip" || {
        echo "[!] Failed to download RobloxPlayer."
        exit 1
    }

    echo -e "[*] Installing Roblox..."
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"
    unzip -o -q "./RobloxPlayer.zip"
    mv "./RobloxPlayer.app" "/Applications/Roblox.app"
    rm -f "./RobloxPlayer.zip"
    echo -e "[✓] Roblox installed."

    echo -e "[*] Downloading Velonix files..."
    curl -s "https://raw.githubusercontent.com/ug32-C9/VelonixMac/main/main/velonix.zip" -o "./velonix.zip" || {
        echo "[!] Failed to download Velonix package."
        exit 1
    }

    echo -e "[*] Installing Velonix..."
    unzip -o -q "./velonix.zip"
    echo -e "[✓] Velonix installed."

    echo -e "[*] Updating dylib..."
    curl -s -O "https://raw.githubusercontent.com/ug32-C9/VelonixMac/main/$channel/libVelonix.dylib"

    echo -e "[*] Patching Roblox..."
    mv ./libVelonix.dylib "/Applications/Roblox.app/Contents/MacOS/libVelonix.dylib"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/libVelonix.dylib" \
        "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" \
        --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -rf "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm -f ./insert_dylib

    echo -e "[*] Installing Velonix App GUI..."
    [ -d "/Applications/Velonix.app" ] && rm -rf "/Applications/Velonix.app"
    mv "./VelonixMac.app" "/Applications/VelonixMac.app"

    rm -f ./velonix.zip ./jq

    echo -e "\n[✓] Installation Complete!"
    echo -e "[Creator] Script made by itzC9 and Frame"
    exit
}

main