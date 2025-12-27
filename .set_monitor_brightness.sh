#!/bin/bash

# VCP code for brightness
BRIGHTNESS_VCP_CODE=10

# --- Function to display usage ---
usage() {
    echo "Usage: $0 <BRIGHTNESS_VALUE>"
    echo "  <BRIGHTNESS_VALUE> must be an integer between 0 and 100."
    exit 1
}

# --- Check for required ddcutil command ---
if ! command -v ddcutil &> /dev/null; then
    echo "Error: ddcutil is not installed or not in PATH."
    echo "Please install ddcutil to use this script."
    exit 1
fi

# --- 1. Validate Input Argument ---
if [ -z "$1" ]; then
    echo "Error: Missing brightness value."
    usage
fi

# Check if argument is a valid number between 0 and 100
if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 0 ] || [ "$1" -gt 100 ]; then
    echo "Error: Brightness value '$1' is invalid."
    usage
fi

NEW_BRIGHTNESS=$1

# --- 2. Detect and Loop through Monitors ---

# The 'ddcutil detect' command prints a list of displays. We filter
# that output to grab the I2C bus number for each detected display.
echo "Scanning for compatible monitors..."
BUS_NUMBERS=$(ddcutil detect 2>/dev/null | grep 'I2C bus:' | awk '{print $NF}' | sed 's#/dev/i2c-##')

if [ -z "$BUS_NUMBERS" ]; then
    echo "No compatible monitors found via ddcutil detect. Exiting."
    exit 0
fi

# --- 3. Apply Brightness Setting ---
echo "Applying brightness: ${NEW_BRIGHTNESS}%"
echo "---"

APPLIED_COUNT=0
for BUS in $BUS_NUMBERS; do
    echo "Applying to bus /dev/i2c-$BUS..."
    # Execute the ddcutil command
    ddcutil --bus $BUS setvcp $BRIGHTNESS_VCP_CODE $NEW_BRIGHTNESS
    if [ $? -eq 0 ]; then
        APPLIED_COUNT=$((APPLIED_COUNT + 1))
    else
        echo "  Warning: Failed to set brightness on bus /dev/i2c-$BUS. Check permissions (e.g., use 'sudo' or udev rules)."
    fi
done

echo "---"
echo "Completed. Applied brightness ${NEW_BRIGHTNESS}% to ${APPLIED_COUNT} monitor(s)."
