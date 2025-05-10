#!/run/current-system/sw/bin/bash

# NOTE: For NixOS, use #!/run/current-system/sw/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Global variables
cols=$(tput cols)
version="1.1"
config_dir="$HOME/.config/bash_alarm"
config_file="$config_dir/config"
history_file="$config_dir/history"
state_file="$config_dir/state"
pause_time=""
last_milestone=0

# Display the help section
display_help() {
    help="$(
        cat <<EOF
    ${BOLD} TIMER ${version}${NC}

    ${BOLD} Usage:${NC}
    $(basename "$0") -h [ hours ] -m [ minutes ] -s [ seconds ]

    ${BOLD} Required:${NC}
    at least one of the options need to be provided of integer type 
    -h hours
    -m minutes
    -s seconds

    ${BOLD} Additional optional args: ${NC}
    -t      text         tag to attach to the timer, define what you are working on 
    -f      file         filename where the audio is located      
    -e      text         action to take after the timer ends
    -c                   load from a configuration file
    -s                   load from the most recent state
    -l                   list the most recent timers
    -v                   display version

    ${PURPLE}${BOLD} Controls: ${NC}
    ctrl + z            stop the timer but instance keeps runnning in the bg
    ctrl + c            resumes from the most recent state


    ${BLUE}If you find any bugs or issues, please report it to me\n${NC}
EOF
    )"
    printf "%b" "${help}"
}

error_msg() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $secs
}

# Center text in terminal by adding padding to the left
center_text() {
    local text=$1
    local width=$(tput cols)
    local padding=$(((width - ${#text}) / 2))
    printf "%${padding}s%s\n" " " "${text}"
}

save_history() {
    mkdir -p "$(dirname "$history_file")"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $hours $minutes $seconds \"$tag\" \"$ring\" \"$end\"" >>"$history_file"
    echo -e "${GREEN}Saved to history file${NC}"
}

save_state() {
    mkdir -p "$(dirname "$state_file")"
    echo "hours=$hours" >"$state_file"
    echo "minutes=$minutes" >>"$state_file"
    echo "seconds=$seconds" >>"$state_file"
    echo "tag=\"$tag\"" >>"$state_file"
    echo "ring=\"$ring\"" >>"$state_file"
    echo "end=\"$end\"" >>"$state_file"
    echo "total_seconds=$total_seconds" >>"$state_file"
    echo "start_time=$start_time" >>"$state_file"
    echo "original_seconds=$original_seconds" >>"$state_file"
    echo -e "${YELLOW}State saved${NC}"
}

check_milestone() {
    local percent=$1
    local milestones=(25 50 75)
    for milestone in "${milestones[@]}"; do
        if [ "$percent" -ge "$milestone" ] && [ "$last_milestone" -lt "$milestone" ]; then
            if command -v notify-send &>/dev/null; then
                notify-send "Timer Progress" "$milestone% complete for task: $tag"
            fi
            last_milestone=$milestone
            break
        fi
    done
}

show_history() {
    if [ -f "$history_file" ]; then
        echo -e "${BOLD}${CYAN}Timer History:${NC}"
        cat "$history_file"
    else
        echo -e "${YELLOW}No history found${NC}"
    fi
    exit 0
}

check_options() {
    if [[ -z $hours && -z $minutes && -z $seconds ]]; then
        error_msg "At least one of -h, -m, or -s must be provided"
    fi
}

default_options() {
    hours=${hours:-0}
    minutes=${minutes:-0}
    seconds=${seconds:-0}
}

config_load() {
    if [ -f "$config_file" ]; then
        source "$config_file"
    else
        default_ring="/usr/share/sounds/freedesktop/stereo/complete.oga"
        default_end="Take a break"
    fi
}

display_progress() {
    local width=$1
    local percent=$2
    local filled=$((width * percent / 100))
    local empty=$((width - filled))
    printf "["
    if [ $filled -gt 0 ]; then
        printf "%${filled}s" | tr ' ' '#'
    fi
    if [ $empty -gt 0 ]; then
        printf "%${empty}s" | tr ' ' '-'
    fi
    printf "]"
}

pause_timer() {
    if [ -z "$pause_time" ]; then
        pause_time=$(date +%s)
        echo -e "\n${YELLOW}Timer paused, press $(fg) to resume${NC}"
    fi
}

resume_timer() {
    if [ -n "$pause_time" ]; then
        local current_time=$(date +%s)
        local pause_duration=$((current_time - pause_time))
        start_time=$((start_time + pause_duration))
        unset pause_time
        echo -e "\n${GREEN}Timer resumed${NC}"
    fi
}

init_timer() {
    hours=${hours:-0}
    minutes=${minutes:-0}
    seconds=${seconds:-0}
    ring=${ring:-$default_ring}
    end=${end:-$default_end}

    # Validate inputs
    if ! [[ "$hours" =~ ^[0-9]+$ && "$minutes" =~ ^[0-9]+$ && "$seconds" =~ ^[0-9]+$ ]]; then
        error_msg "Hours, minutes, and seconds must be non-negative integers"
    fi

    # Convert to seconds
    total_seconds=$((hours * 3600 + minutes * 60 + seconds))

    if [ $total_seconds -le 0 ]; then
        error_msg "Timer duration must be greater than 0"
    fi

    start_time=$(date +%s)
    original_seconds=$total_seconds
}

run_timer() {
    clear
    echo -e "${BOLD}${BLUE}Timer${NC}"
    echo -e "${BLUE}Task:${NC} $tag"
    echo -e "${BLUE}Duration:${NC} $(format_time $total_seconds)"
    echo -e "${BLUE}End action:${NC} $end"
    echo ""

    # hide the cursor
    tput civis

    while [ $total_seconds -gt 0 ]; do
        if [ -n "$pause_time" ]; then
            sleep 1
            continue
        fi

        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local adjusted_total=$((original_seconds - elapsed))

        if [ $adjusted_total -lt 0 ]; then
            adjusted_total=0
        fi

        total_seconds=$adjusted_total
        local progress=$((100 - (total_seconds * 100 / original_seconds)))

        local bar_width=$((cols > 80 ? 50 : (cols / 2 > 10 ? cols / 2 - 10 : 10)))

        local elapsed_formatted=$(format_time $elapsed)
        local remaining_formatted=$(format_time $total_seconds)

        check_milestone $progress

        echo -ne "\r${YELLOW}$(display_progress $bar_width $progress) ${BOLD}${progress}%${NC}"
        echo -ne " | ${GREEN}Elapsed: ${elapsed_formatted}${NC} | ${RED}Remaining: ${remaining_formatted}${NC}  "

        sleep 1

        if [ $total_seconds -le 0 ]; then
            break
        fi
    done

    echo ""

    ## show cursor
    tput cnorm
}

## play alarm
play_alarm() {
    echo ""
    center_text "╔══════════════════════════════════════╗"
    center_text "║          Timer Complete!             ║"
    center_text "╚══════════════════════════════════════╝"
    echo ""
    center_text "Task: $tag"
    echo ""

    if [ -f "$ring" ]; then
        if command -v paplay &>/dev/null; then
            paplay "$ring" &
        elif command -v aplay &>/dev/null; then
            aplay "$ring" &
        elif command -v afplay &>/dev/null; then
            afplay "$ring" &
        else
            echo -e "${YELLOW}Warning: No audio player found. Cannot play sound.${NC}"
        fi
    else
        echo -e "${YELLOW}Warning: Sound file not found: $ring${NC}"
    fi

    if command -v notify-send &>/dev/null; then
        notify-send -u critical "Timer Complete" "Task: $tag is finished!"
    fi

    if [ -n "$end" ]; then
        echo -e "${GREEN}Next action: $end${NC}"
    fi

    if [ -f "$state_file" ]; then
        rm "$state_file"
    fi
}

## main function
main() {

    ## NOTE: pause and resume functonality is not working currnetly
    trap pause_timer SIGTSTP                 # to pause:  Ctrl+Z
    trap resume_timer SIGCONT                # to resume: Ctrl+Z
    trap 'save_state; exit 0' SIGINT SIGTERM # to save state and exit:  Ctrl+C

    # Parse command line arguments
    hours=""
    minutes=""
    seconds=""
    tag=""
    ring=""
    end=""
    use_config=false
    resume=true
    list_history=false

    while getopts ":h:m:s:t:f:e:crlv" opt; do
        case $opt in
        h) hours=$OPTARG ;;
        m) minutes=$OPTARG ;;
        s) seconds=$OPTARG ;;
        t) tag=$OPTARG ;;
        f) ring=$OPTARG ;;
        e) end=$OPTARG ;;
        c) use_config=true ;;
        r) resume=true ;;
        l) list_history=true ;;
        v)
            echo "Version $version"
            exit 0
            ;;
        \?) error_msg "Invalid option: -$OPTARG" ;;
        esac
    done

    if [ "$list_history" = true ]; then
        show_history
    fi

    config_load

    if [ "$resume" = true ] && [ -f "$state_file" ]; then
        source "$state_file"
        echo -e "${GREEN}Resumed from saved state${NC}"

    elif [ "$use_config" = true ] && [ -f "$config_file" ]; then
        source "$config_file"

    elif [[ -z $hours && -z $minutes && -z $seconds ]]; then

        read -rp "Enter hours: " hours
        read -rp "Enter minutes: " minutes
        read -rp "Enter seconds: " seconds
        read -rp "Enter task description: " tag
        read -rp "Enter sound file path (or leave empty for default): " ring
        read -rp "Enter end action (or leave empty for default): " end

    fi

    default_options

    check_options

    init_timer

    save_history

    run_timer

    play_alarm
}

main "$@"
