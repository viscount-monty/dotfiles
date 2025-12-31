#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================

# Colors and formatting (using $'...' ensures actual escape characters are stored)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m' # No Color

# Log Setup
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
TEMP_LOG="/tmp/update_script_${TIMESTAMP}.tmp"
FINAL_LOG="./update_error_${TIMESTAMP}.log"
ERROR_COUNT=0

# Ensure pipefail is on so we catch errors even when piping output
set -o pipefail

# Hide cursor to avoid flickering, restore on exit
trap "tput cnorm; exit" INT TERM EXIT
tput civis

# ==========================================
# FUNCTIONS
# ==========================================

# Helper to truncate text to fit the screen width
get_truncated_output() {
  local text="$1"
  local max_width=$(($(tput cols) - 35)) # Leave room for the label and status
  if [ ${#text} -gt $max_width ]; then
    echo "${text:0:$max_width}..."
  else
    echo "$text"
  fi
}

update_manager() {
  local MANAGER_NAME=$1
  local CHECK_CMD=$2
  local UPDATE_CMD=$3

  # 1. Check if manager exists
  if ! command -v "$CHECK_CMD" &>/dev/null; then
    # Now passing the color vars directly in printf arguments will work
    printf "%-12s [ ${YELLOW}%-7s${NC} ] ${DIM}%s${NC}\n" "$MANAGER_NAME" "SKIPPED" "Not found on system"
    echo "--- $MANAGER_NAME not found on system ---" >>"$TEMP_LOG"
    return
  fi

  # 2. Log Header
  echo -e "\n\n========== UPDATING $MANAGER_NAME ==========" >>"$TEMP_LOG"

  # 3. Execution with Live Feedback
  eval "$UPDATE_CMD" 2>&1 | tee -a "$TEMP_LOG" | while IFS= read -r line; do
    clean_line=$(echo "$line" | tr -d '\r' | tr -d '\n')
    display_line=$(get_truncated_output "$clean_line")

    # \r moves cursor to start of line, tput el clears line
    printf "\r%-12s ${BLUE}> %-s${NC}" "$MANAGER_NAME" "$display_line"
    tput el
  done

  # 4. Check status
  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    printf "\r%-12s [ ${GREEN}%-7s${NC} ]" "$MANAGER_NAME" "SUCCESS"
    tput el
    echo ""
  else
    printf "\r%-12s [ ${RED}%-7s${NC} ]" "$MANAGER_NAME" "FAILED"
    tput el
    echo ""
    ((ERROR_COUNT++))
  fi
}

# ==========================================
# MAIN EXECUTION
# ==========================================

echo -e "${BOLD}System Update Utility${NC}"
echo "-----------------------------------"

# 1. APT
update_manager "APT" "apt" "sudo apt update && sudo apt full-upgrade -y"

# 2. PACMAN
update_manager "Pacman" "pacman" "sudo pacman -Syu --noconfirm"

# 3. YAY
update_manager "Yay" "yay" "yay -Syu --noconfirm"

# 4. FLATPAK
update_manager "Flatpak" "flatpak" "flatpak update -y"

echo "-----------------------------------"

# ==========================================
# LOG HANDLING
# ==========================================

if [ $ERROR_COUNT -eq 0 ]; then
  echo -e "${GREEN}All detected systems updated successfully.${NC}"
  rm "$TEMP_LOG"
else
  echo -e "${RED}$ERROR_COUNT error(s) occurred.${NC}"
  mv "$TEMP_LOG" "$FINAL_LOG"
  echo -e "Error log saved to: ${BOLD}$FINAL_LOG${NC}"
fi
