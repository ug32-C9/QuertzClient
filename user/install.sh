#!/bin/bash

main() {
    clear
    echo -e "[ Velonix Mac Installer (Non-Admin) ] Starting..."

    echo -e "[*] Fetching jq (JSON parser)..."
    curl -s "https://git.raptor.fun/main/jq-macos-amd64" -o "./jq" || {
        echo "[!] Failed to download jq."
        exit 1
    }
    chmod +x ./jq

    [ -d "Applications" ] || mkdir "Applications"

    echo -e "[*] Fetching latest Roblox version info..."
    local versionInfo=$(curl -s "https://raw.githubusercontent.com/ug32-C9/VelonixMac/main/version.json")
    local channel=$(echo "$versionInfo" | ./jq -r ".channel")
    local version=$(echo "$versionInfo" | ./jq -r ".\"roblox-client\"")

    echo -e "[*] Downloading Roblox v$version..."
    [ -f "./RobloxPlayer.zip" ] && rm -f "./RobloxPlayer.zip"
    curl -s "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip" || {
        echo "[!] Failed to download Roblox zip."
        exit 1
    }

    echo -e "[*] Installing Roblox locally..."
    [ -d "Applications/Roblox.app" ] && rm -rf "Applications/Roblox.app"
    unzip -o -q "./RobloxPlayer.zip"
    mv "./RobloxPlayer.app" "./Applications/Roblox.app"
    rm -f "./RobloxPlayer.zip"
    echo -e "[✓] Roblox installed."

    echo -e "[*] Downloading Velonix package..."
    curl -s "https://raw.githubusercontent.com/ug32-C9/VelonixMac/main/main/velonix.zip" -o "./velonix.zip"

    echo -e "[*] Installing Velonix..."
    unzip -o -q "./velonix.zip"
    echo -e "[✓] Velonix installed."

    echo -e "[*] Updating Dylib library..."
    curl -s -O "https://raw.githubusercontent.com/ug32-C9/VelonixMac/main/$channel/libVelonix.dylib"

    echo -e "[*] Patching Roblox executable..."
    local pat=$(pwd)
    mv ./libVelonix.dylib "$pat/Applications/Roblox.app/Contents/MacOS/libVelonix.dylib"
    ./insert_dylib "$pat/Applications/Roblox.app/Contents/MacOS/libVelonix.dylib" \
                   "$pat/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" \
                   --strip-codesig --all-yes
    mv "$pat/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" \
       "$pat/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"

    rm -rf "Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm -f ./insert_dylib

    echo -e "[*] Installing Velonix App GUI..."
    [ -d "Applications/Velonix.app" ] && rm -rf "Applications/Velonix.app"
    mv "./VelonixMac.app" "./Applications/VelonixMac.app"

    rm -f ./velonix.zip ./jq

    echo -e "\n[✓] Install Complete!"
    echo -e "[Creator] Script built by itzC9 and Frame"
    exit
}

main