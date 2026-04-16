#!/bin/bash

if [[ "$AUTO_UPDATE" != "1" ]]; then
    echo "❌ Auto Update is disabled. Enable it for automatic server updates."
    exit 0
fi

SERVER_DIRECTORY="/home/container"
if [[ -d /mnt/server ]]; then
    SERVER_DIRECTORY="/mnt/server"
fi

WEBPAGE_URL="https://nightly.multitheftauto.com/"

# Validate VERSION_OVERRIDE — must be a pure integer (build number)
if [[ -n "$VERSION_OVERRIDE" && "$VERSION_OVERRIDE" =~ ^[0-9]+$ ]]; then
    filename="multitheftauto_linux_x64-1.6.0-rc-${VERSION_OVERRIDE}.tar.gz"
    full_download_link="https://nightly.multitheftauto.com/$filename"
    echo "📌 Version override set. Targeting build: $VERSION_OVERRIDE"
else
    if [[ -n "$VERSION_OVERRIDE" ]]; then
        echo "⚠️  VERSION_OVERRIDE '${VERSION_OVERRIDE}' is invalid (expected a build number, e.g. 24056). Falling back to latest."
    fi

    webpage_content=$(curl -s "$WEBPAGE_URL")
    download_link=$(echo "$webpage_content" | grep -oP 'href="(multitheftauto_linux_x64-1\.6\.0-rc-\d+\.tar\.gz)"' | sed 's/href="//;s/"//' | head -n 1)

    if [[ -z "$download_link" ]]; then
        echo "⚠️  No download link found on the nightly page. Skipping update."
        exit 0
    fi

    filename="$download_link"
    full_download_link="https://nightly.multitheftauto.com/$filename"
    echo "🔍 Latest build found: $full_download_link"
fi

echo "⬇️  Downloading: $full_download_link"
curl -sf -O "$full_download_link"

if [[ $? -ne 0 || ! -f "$filename" ]]; then
    echo "❌ Download failed (file not found or HTTP error). Skipping update."
    exit 1
fi

tar -xzf "$filename" --strip-components=1 -C "$SERVER_DIRECTORY"
if [[ $? -ne 0 ]]; then
    echo "❌ Extraction failed. Skipping update."
    rm -f "$filename"
    exit 1
fi

rm "$filename"
echo "✅ Successfully updated the MTA Server."
