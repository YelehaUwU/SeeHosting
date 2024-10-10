#!/bin/bash

function download_and_extract() {
    SERVER_DIRECTORY="/home/container"

    if [[ -d /mnt/server ]]; then
        SERVER_DIRECTORY="/mnt/server"
    fi

    WEBPAGE_URL="https://nightly.multitheftauto.com/"

    webpage_content=$(curl -s "$WEBPAGE_URL")

    download_link=$(echo "$webpage_content" | grep -oP 'href="(multitheftauto_linux_x64-1\.6\.0-rc-\d+\.tar\.gz)"' | sed 's/href="//;s/"//' | head -n 1)

    if [[ -z "$download_link" ]]; then
        echo "No download link found."
        return 1
    fi

    full_download_link="https://nightly.multitheftauto.com/$download_link"

    echo "Download link: $full_download_link"

    curl -O "$full_download_link"

    filename=$(basename "$full_download_link")

    if [[ ! -f "$filename" ]]; then
        echo "Download failed."
        return 1
    fi

    tar -xvzf "$filename" --strip-components=1 -C "$SERVER_DIRECTORY"

    if [[ $? -ne 0 ]]; then
        echo "Extraction failed."
        return 1
    fi

    rm "$filename"

    echo "File downloaded and extracted successfully to the server."
    return 0
}

if [[ $AUTO_UPDATE == 1 ]]; then
    download_and_extract
    if [[ $? -ne 0 ]]; then
        echo "Update process failed."
    fi
fi
