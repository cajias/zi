#!/bin/zsh

script_dir="$(cd "$(dirname "$0")" && pwd)"
timestamp_file="${script_dir}/.daily_script_timestamp"
touch "${timestamp_file}"

ALERT='\033[1;33m' # Yellow
NC='\033[0m' # No Color
bold=$(tput bold)
normal=$(tput sgr0)
RED='\033[0;31m'
YELLOW='\033[1;33m'

# Function to show a spinner in Zsh on macOS
spinner() {
    local pid=$1
    local delay=0.2
    local spin="-\|/"

    while ps -p $pid > /dev/null; do
        for i in {1..4}; do
            echo -n "$(tput el) "  # Clear the line and print a space
        done

        for ((i = 0; i < ${#spin}; i++)); do
            char="${spin[i+1]}"
            echo -ne "\r${char}"  # Print the spinner
            sleep $delay
        done
    done

    echo -e "\r"  # Clear the spinner line
}

last_timestamp=$(cat "$timestamp_file")
curr_timestamp=$(date +%U) # week of year
output_file=$(mktemp)
if [ -z "$last_timestamp" ] || [ "${curr_timestamp}" -ne "${last_timestamp}" ]; then
    # Update the timestamp file with today's date
    date +%Y%m%d > "$timestamp_file"
    brew outdated > "${output_file}" > /dev/null 2>&1 &
    disown $command_pid
    command_pid=$!
    spinner ${command_pid}
    wait $command_pid > /dev/null 2>&1
fi

if [ -z "$(cat "${output_file}")" ]; then
    exit 0
fi

packages=$(cat "${output_file}")
echo "${ALERT}"
echo "=========================================="
echo "  Homebrew Updates Available"
echo ""
echo "${packages}"
echo ""
echo "${bold} To update run \"${ALERT}brew upgrade${NC}\"."
echo "=========================================="
confirmation=
vared -p "Update now? [Y]/n: " -c confirmation
if [ -z "${confirmation}" ] || [ "${confirmation}" = "y" ] || [ "${confirmation}" = "Y" ]; then
    # Add the custom string and execute the user's command
    brew upgrade
fi

