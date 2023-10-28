#!/bin/zsh
script_dir="$(cd "$(dirname "$0")" && pwd)"
timestamp_file="${script_dir}/.daily_script_timestamp"

ALERT='\033[1;33m' # Yellow
NC='\033[0m' # No Color
bold=$(tput bold)
normal=$(tput sgr0)
RED='\033[0;31m'
YELLOW='\033[1;33m'

update_command="brew upgrade"
find_outdated_command="brew outdated"

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

update_packages(){    
    output=$1
    if [ -z ${output} ];then
        return
    fi
    echo "${ALERT}"
    echo "=========================================="
    echo "  Homebrew Updates Available"
    echo ""
    echo "${output}"
    echo ""
    echo "${bold} To update run \"${ALERT}${update_command}${NC}\"."
    echo "=========================================="
    vared -p "Update now? [Y/n]: " -c confirmation
    confirmation=${confirmation:-y}  # Default to "y" if no input within 5 seconds

    if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ]; then
        # Add the custom string and execute the user's command
        echo "${update_command}" | bash
        return
    fi
}

if [ ! -e "$timestamp_file" ] || [ "$(date +%Y%m%d)" -ne "$(cat "$timestamp_file")" ]; then
    brew outdated &
    command_pid=$!
    spinner ${command_pid}
    command_output=$(wait $command_pid 2>/dev/null)

    update_packages ${command_output}

    # Update the timestamp file with today's date
    date +%Y%m%d > "$timestamp_file"
fi

