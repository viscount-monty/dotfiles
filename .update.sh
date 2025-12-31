#!/bin/bash

# ==========================================
# CONFIGURATION & VISUALS
# ==========================================

# Define Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Log Setup
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
TEMP_LOG="/tmp/update_script_${TIMESTAMP}.tmp"
FINAL_LOG="./update_error_${TIMESTAMP}.log"
ERROR_COUNT=0

# Create temp log
touch "$TEMP_LOG"

# Header
echo -e "${BOLD}System Update Utility${NC}"
echo "-----------------------------------"

# Refresh sudo credentials upfront so prompts don't break the UI
# We only ask if the user isn't already root
if [ "$EUID" -ne 0 ]; then
  sudo -v
fi

# ==========================================
# FUNCTIONS
# ==========================================

update_manager() {
  local MANAGER_NAME=$1
  local CHECK_CMD=$2
  local UPDATE_CMD=$3

  # 1. Check if the package manager exists
  if ! command -v "$CHECK_CMD" &>/dev/null; then
    printf "%-20s [ ${YELLOW}%-7s${NC} ]\n" "$MANAGER_NAME" "SKIPPED"
    echo "--- $MANAGER_NAME not found on system ---" >>"$TEMP_LOG"
    return
  fi

  # 2. Visual: Print "Updating..."
  # %-20s ensures fixed width for alignment
  printf "%-20s " "$MANAGER_NAME"

  # 3. Log Header
  echo -e "\n\n========== UPDATING $MANAGER_NAME ==========" >>"$TEMP_LOG"

  # 4. Run the update command
  # Redirect stdout and stderr to the log file
  # use 'eval' to handle complex command strings
  if eval "$UPDATE_CMD" >>"$TEMP_LOG" 2>&1; then
    # Success
    printf "[ ${GREEN}%-7s${NC} ]\n" "SUCCESS"
  else
    # Failure
    printf "[ ${RED}%-7s${NC} ]\n" "FAILED"
    ((ERROR_COUNT++))
  fi
}

# ==========================================
# EXECUTION
# ==========================================

# 1. APT (Debian/Ubuntu)
# Updates repos and upgrades packages
update_manager "APT" "apt" "sudo apt update && sudo apt full-upgrade -y"

# 2. PACMAN (Arch Linux)
# Syncs DB and updates system
update_manager "Pacman" "pacman" "sudo pacman -Syu --noconfirm"

# 3. YAY (Arch AUR Helper)
# Only runs if yay exists. Note: yay usually should not be run as root,
# but if the script is run as user, yay handles its own sudo prompts.
update_manager "Yay" "yay" "yay -Syu --noconfirm"

# 4. FLATPAK (Universal)
update_manager "Flatpak" "flatpak" "flatpak update -y"

echo "-----------------------------------"

# ==========================================
# LOG HANDLING
# ==========================================

if [ $ERROR_COUNT -eq 0 ]; then
  echo -e "${GREEN}All detected systems updated successfully.${NC}"
  # Remove the temp log as requested (only keep if fails)
  rm "$TEMP_LOG"
else
  echo -e "${RED}$ERROR_COUNT error(s) occurred.${NC}"
  # Move temp log to final permanent location
  mv "$TEMP_LOG" "$FINAL_LOG"
  echo -e "Error log saved to: ${BOLD}$FINAL_LOG${NC}"
fi
