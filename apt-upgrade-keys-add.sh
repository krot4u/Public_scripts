#!/bin/bash

# Array to store missing keys
missing_keys=()

# Function to add missing keys
add_missing_keys() {
    for key in "${missing_keys[@]}"
    do
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$key"
    done
}

# Main script

echo "Running apt-get update..."
output=$(sudo apt-get update --allow-releaseinfo-change 2>&1)
# Check if any missing keys error occurred
if [[ $output =~ "NO_PUBKEY" ]]; then
    echo "Upgrade encountered an error."
    echo "Parsing missing keys..."
    while IFS= read -r line; do
        if [[ $line =~ "NO_PUBKEY" ]]; then
            key=$(echo "$line" | awk '{print $NF}')
            missing_keys+=("$key")
        fi
    done <<< "$output"
    
    # Add missing keys and run update again
    echo "Adding missing keys and running update again..."
    add_missing_keys
    sudo apt-get update -y --allow-releaseinfo-change
else
    echo "Upgrade completed successfully."
fi
